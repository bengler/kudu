# encoding: utf-8
require "json"
require 'pebblebed/sinatra'
require 'sinatra/petroglyph'
require 'sinatra/reloader'

class KuduV1 < Sinatra::Base
  set :root, "#{File.dirname(__FILE__)}/v1"

  register Sinatra::Pebblebed
  i_am :kudu

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
  put '/items/:uid/touch' do |uid|
    require_identity
    item = Item.find_or_create_by_external_uid(uid)

    if item.new_record?
      item.save!
      halt 201
    end
    response.status = 201
  end

  # Query for items/summaries, this probably needs pagination
  get '/items/:uids' do
    uids = params[:uids].split(",")
    items = Item.find_all_by_external_uid(uids)
    pg :items, :locals => {:items => items}
  end

  get '/ping' do
    failures = []
    begin
      ActiveRecord::Base.verify_active_connections!
      ActiveRecord::Base.connection.execute("select 1")
    rescue Exception => e
      failures << "ActiveRecord: #{e.message}"
    end

    if failures.empty?
      halt 200, "kudu"
    else
      halt 503, failures.join("\n")
    end
  end

  get '/items/:path/sample' do |path|
    halt 500, "Limit is not specified" unless params[:limit]

    items = Item.combine_resultsets(path, DeepStruct.wrap(params), current_identity.id).flatten

    pg :items, :locals => {:items => items}
  end

  # route for letting the test framework do a single line of logging
  get '/log/:this' do
    logger.info params[:this]
  end
end