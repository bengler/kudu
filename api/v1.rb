# encoding: utf-8
require "json"
require 'pebblebed/sinatra'

class KuduV1 < Sinatra::Base
  set :root, "#{File.dirname(__FILE__)}/v1"

  register Sinatra::Pebblebed
  i_am :kudu

  Rabl.register!

  helpers do

    def logger
      Log
    end

  end

  # Get a single Ack for current identity
  get '/acks/:uid' do |uid|
    require_identity

    item = Item.find_by_external_uid(uid)
    @ack = item ? Ack.find_by_item_id(item.id, current_identity.id) : {}
    response.status = 200
    render :rabl, :ack, :format => :json
  end

  # Create a single Ack for current identity
  post '/acks/:uid' do |uid|
    require_identity

    ack = params[:ack]

    halt 500, "invalid score #{ack['score'].inspect}" unless ack['score'] and Integer(ack['score'])
    item = Item.find_or_create_by_external_uid(uid)
    @ack = Ack.create_or_update(item, current_identity.id, :score => ack['score'])
    @ack.save!
    response.status = 201
    render :rabl, :ack, :format => :json
  end

  # Update a single Ack for current identity
  put '/acks/:uid' do |uid|
    require_identity

    ack = params[:ack]

    halt 500, "invalid score #{ack['score'].to_s}" unless ack['score'] and Integer(ack['score'])
    item = Item.find_or_create_by_external_uid(uid)
    @ack = Ack.create_or_update(item, current_identity.id, :score => ack['score'])
    @ack.save!
    render :rabl, :ack, :format => :json
  end

  # Delete a single Ack
  delete '/acks/:uid' do |uid|
    require_identity

    item = Item.find_by_external_uid(uid)
    ack = Ack.find_by_item_id(item.id, current_identity.id)
    ack.destroy
    response.status = 204
  end

  # Query for items/summaries, this probably needs pagination
  get '/items/:uids' do
    uids = params[:uids].split(",")
    @items = Item.find_all_by_external_uid(uids)
    render :rabl, :items, :format => :json
  end

  # route for letting the test framework do a single line of logging
  get '/log/:this' do
    logger.info params[:this]
  end

end
