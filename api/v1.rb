# encoding: utf-8
require "json"

class KuduV1 < Sinatra::Base

  helpers do

    def logger
      Log
    end

    def checkpoint_session
      request.cookies['checkpoint.session']
    end

    def require_identity
      halt 403, "Client (#{request.host}) failed to provide session info" unless checkpoint_session
      identity = pebbles.checkpoint.me
      halt 403, "Checkpoint sez: No identity matches #{checkpoint_session}" unless identity
      identity
    end

    def pebbles
      @pebbles ||= Pebbles::Connector.new(checkpoint_session, :host => request.host)
    end

  end

  # Create or update a single Ack
  get '/acks' do
    Ack.all.to_json
  end


  # Create or update a single Ack
  post '/acks/:uid' do |uid|
    uid = CGI.unescape(uid) if uid
    halt 500, "missing params" unless (uid && params[:score] )
    halt 500, "invalid score" unless Integer(params[:score])
    item = Item.find_or_create_by_external_uid(uid)
    ack = Ack.create_or_update(item, require_identity.id, :score => params[:score])
    response.status = ack.new_record? ? 201 : 200
    ack.save!
    {:results => [ack]}.to_json
  end

  # Delete a single Ack
  delete '/acks/:uid' do |uid|
    uid = CGI.unescape(uid) if uid
    halt 400, "missing params" unless (uid)
    item = Item.find_by_external_uid(uid)
    ack = Ack.find_by_item_id(item.id, require_identity.id)
    ack.destroy
    response.status = 204
    {:results => [ack]}.to_json
  end

  # Query for Acks, this probably needs pagination
  get '/items/:uids' do
    uids = params[:uids].split(",").collect {|uid| CGI.unescape(uid) }
    {:results => Item.find_all_by_external_uid(uids)}.to_json
  end

  # Query for Acks, this probably needs pagination
  get '/items' do
    scope = Item.scoped.limit(params[:limit] || 10).offset(params[:offset] || 0)
    scope = scope.where(:path => params[:path]) if params[:path]
    {:results => scope}.to_json
  end

  # route for letting the test framework do a single line of logging
  get '/log/:this' do
    logger.info params[:this]
  end


end
