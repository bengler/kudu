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

  end


  # Create or update a single Ack
  post '/ack/:uid' do |uid|
    uid = CGI.unescape(uid) if uid
    halt 500, "missing params" unless (uid && params[:score] )
    halt 500, "invalid score" unless Integer(params[:score])
    identity = identity_from_session
    ack = Ack.create_or_update(uid, identity, :score => params[:score])
    response.status = ack.new_record? ? 201 : 200
    json_from_summary(ack.summary)
  end

  # Delete a single Ack
  delete '/ack/:uid' do |uid|
    uid = CGI.unescape(uid) if uid
    halt 400, "missing params" unless (uid)
    identity = identity_from_session
    ack = Ack.find_by_external_uid_and_identity(uid, identity)
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

  private

  # TODO: implement this as it should be, using checkpoint goodness
  def identity_from_session
    1337
  end

end
