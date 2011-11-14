# encoding: utf-8
require "json"

class KuduV1 < Sinatra::Base

  helpers do

    def logger
      Log
    end

    # TODO: put this in Summary
    def json_from_summary(summary)
      result = {}
      if summary.is_a? Array
        result["results"] = summary || []
      else
        result["results"] = [summary] || []
      end
      result.to_json
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
      @pebbles = Pebbles::Connector.new(checkpoint_session, :host => request.host)
    end

  end


  # Create or update a single Ack
  post '/ack/:uid' do |uid|
    uid = CGI.unescape(uid) if uid
    halt 500, "missing params" unless (uid && params[:score] )
    halt 500, "invalid score" unless Integer(params[:score])
    ack = Ack.create_or_update(uid, require_identity.id, :score => params[:score])
    response.status = ack.new_record? ? 201 : 200
    ack.save!
    json_from_summary(ack)
  end

  # Delete a single Ack
  delete '/ack/:uid' do |uid|
    uid = CGI.unescape(uid) if uid
    halt 400, "missing params" unless (uid)
    ack = Ack.find_by_external_uid_and_identity(uid, require_identity.id)
    ack.destroy
    response.status = 204
    json_from_summary(ack.summary)
  end

  # Query for Acks, this probably needs pagination
  get '/summary' do
    result = nil
    if params[:uid]
      uid = CGI.unescape(params[:uid])
      result = json_from_summary(Summary.find_by_external_uid(uid))
    elsif params[:uids]
      uids = params[:uids].split(",").collect {|uid| CGI.unescape(uid) }
      result = json_from_summary(Summary.find_all_by_external_uid(uids))
    end
    response.status = 200
    result
  end

  # route for letting the test framework do a single line of logging
  get '/log/:this' do
    logger.info params[:this]
  end


end
