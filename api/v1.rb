# encoding: utf-8
require "json"

class KuduV1 < Sinatra::Base
  Rabl.register!

  helpers do

    def logger
      Log
    end

    def checkpoint_session
      request.cookies['checkpoint.session']
    end

    def current_identity
      pebbles.checkpoint.me
    end

    def require_identity
      unless current_identity.respond_to?(:id)
        halt 403, "Checkpoint: No identity matches #{checkpoint_session}"
      end
    end

    def pebbles
      @pebbles ||= Pebbles::Connector.new(checkpoint_session, :host => request.host)
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

    halt 500, "invalid score #{params[:score].inspect}" unless params[:score] and Integer(params[:score])
    item = Item.find_or_create_by_external_uid(uid)
    @ack = Ack.create_or_update(item, current_identity.id, :score => params[:score])
    @ack.save!
    response.status = 201
    render :rabl, :ack, :format => :json
  end

  # Update a single Ack for current identity
  put '/acks/:uid' do |uid|
    require_identity

    halt 500, "invalid score #{params[:score].to_s}" unless params[:score] and Integer(params[:score])
    item = Item.find_or_create_by_external_uid(uid)
    @ack = Ack.create_or_update(item, current_identity.id, :score => params[:score])
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
