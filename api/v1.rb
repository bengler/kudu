# encoding: utf-8
require "json"
require 'pebblebed/sinatra'
require 'sinatra/petroglyph'
require 'sinatra/reloader'

class KuduV1 < Sinatra::Base
  set :root, "#{File.dirname(__FILE__)}/v1"

  register Sinatra::Pebblebed

  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/item.rb'
    also_reload 'lib/ack.rb'
  end

  helpers do

    def logger
      Log
    end

  end

  # Get Acks for item(s) for  current identity
  get '/acks/:uids' do |uids|
    require_identity
    uids = params[:uids].split(",")
    items = Item.find_all_by_external_uid(uids)
    acks = Ack.find_all_by_item_id(items, current_identity.id)
    response.status = 200
    pg :acks, :locals => {:acks => acks}
  end

  # Create a single Ack for current identity
  post '/acks/:uid' do |uid|
    require_identity

    ack = params[:ack]

    halt 500, "Missing ack object in post body" if ack.nil?
    halt 500, "Invalid score #{ack['score'].inspect}" unless ack['score'] and Integer(ack['score'])
    item = Item.find_or_create_by_external_uid(uid)
    ack = Ack.create_or_update(item, current_identity.id, :score => ack['score'])
    ack.save!
    response.status = 201
    pg :ack, :locals => {:ack => ack}
  end

  get '/acks/:uid/count' do |uid|
    # TODO: Implement properly. For now just return the full count to
    # get dittforslag.no out the door.
    {:uid => uid, :count => Ack.count, 
      :note => "Not fully implemented! Returns the full ack count for all realms and paths always."}.to_json
  end    

  # Update a single Ack for current identity
  put '/acks/:uid' do |uid|
    require_identity

    ack = params[:ack]

    halt 500, "Invalid score #{ack['score'].to_s}" unless ack['score'] and Integer(ack['score'])
    item = Item.find_or_create_by_external_uid(uid)
    ack = Ack.create_or_update(item, current_identity.id, :score => ack['score'])
    ack.save!
    pg :ack, :locals => {:ack => ack}
  end

  # Delete a single Ack
  delete '/acks/:uid' do |uid|
    require_identity

    item = Item.find_by_external_uid(uid)
    ack = Ack.find_by_item_id(item.id, current_identity.id)
    ack.destroy
    response.status = 204
  end

  # Create an item (to preserve creation date for items)
  # This is idempotent
  # todo: write tests
  # todo: remove duplicate
  put '/items/:uid/touch' do |uid|
    require_identity
    item = Item.find_or_create_by_external_uid(uid)

    if item.new_record?
      item.save!
      response.status = 201
    end
    "Ok"
  end

  # Create an item (to preserve creation date for items)
  # This is idempotent
  # todo: write tests
  # todo: remove duplicate
  post '/items/:uid/touch' do |uid|
    require_identity
    item = Item.find_or_create_by_external_uid(uid)

    if item.new_record?
      item.save!
      response.status = 201
    end
    "Ok"
  end

  # Query for items/summaries, this probably needs pagination
  get '/items/:uids' do
    uids = params[:uids].split(",")
    items = Item.find_all_by_external_uid(uids)
    pg :items, :locals => {:items => items}
  end

  get '/items/:path/sample' do |path|
    halt 500, "Limit is not specified" unless params[:limit]
    halt 500, "Missing segments" unless params[:segments]

    # sanity check parameters
    allowed_fields = Item.columns.map {|c| c.name}
    segments = params[:segments].map do |segment|
      halt 500, "Invalid field '#{segment['field']}'" unless allowed_fields.include? segment['field']
      halt 500, "Invalid order '#{segment['order']}'" unless segment['order'].nil? || %w(asc desc).include?(segment['order'])
      {
        :field => segment['field'],
        :order => segment['order'],
        :percent => Float(segment['percent'] || 100).ceil,
        :sample_size => segment['sample_size'] && Float(segment['sample_size'])
      }
    end

    identity_id = params[:include_own] && %w(true t 1 y).include?(params[:include_own]) ? nil : current_identity.try(:id)
    shuffle = params[:shuffle].nil? || %w(true t 1 y).include?(params[:shuffle])

    sane_params = DeepStruct.wrap ({
      :limit => params[:limit].to_i,
      :shuffle => shuffle,
      :segments => segments,
      :identity_id => identity_id
    })

    items = Item.combine_resultsets(path, sane_params).flatten

    pg :items, :locals => {:items => items}
  end
end
