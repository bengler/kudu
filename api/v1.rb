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

  # Get all acks
  get '/acks' do
    @acks = Ack.all
    render :rabl, :acks, :format => :json
  end

  # Create or update a single Ack
  post '/acks/:uid' do |uid|
    require_identity

    halt 500, "missing params" unless (uid && params[:score] )
    halt 500, "invalid score" unless Integer(params[:score])
    item = Item.find_or_create_by_external_uid(uid)
    @ack = Ack.create_or_update(item, current_identity.id, :score => params[:score])
    response.status = @ack.new_record? ? 201 : 200
    @ack.save!
    render :rabl, :ack, :format => :json
  end

  # Delete a single Ack
  delete '/acks/:uid' do |uid|
    require_identity

    halt 400, "missing params" unless (uid)
    item = Item.find_by_external_uid(uid)
    ack = Ack.find_by_item_id(item.id, current_identity.id)
    ack.destroy
    response.status = 204
  end

  # Query for Acks, this probably needs pagination
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
