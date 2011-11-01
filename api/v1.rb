# encoding: utf-8
require "json"

class KuduV1 < Sinatra::Base
  
  helpers do

    def logger
      Log
    end

    # put this in Summary
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


  # create or update a single Ack
  # TODO: figure out how how to transfer params[:collection] to ack.summary 
  post '/ack/:uid' do
    halt 500, "missing params" unless (params[:uid] && params[:score] )
    halt 500, "invalid score" unless Integer(params[:score])
    identity = identity_from_session
    ack = Ack.create_or_update(params[:uid], identity, :score => params[:score])
    response.status = ack.new_record? ? 201 : 200
    json_from_summary(ack.summary)
  end

  # delete a single Ack
  delete '/ack/:uid' do
    halt 400, "missing params" unless (params[:uid])
    identity = identity_from_session
    ack = Ack.find_by_external_uid_and_identity(params[:uid], identity)
    ack.destroy
    response.status = 204
    json_from_summary(ack.summary)
  end

  # query for Acks, this probably needs pagination
  get '/summary' do
    result = nil
    if params[:collection]
      result = json_from_summary(Summary.where(:collection => params[:collection]))
    elsif params[:uid]
      result = json_from_summary(Summary.find_by_external_uid(params[:uid]))
    elsif params[:uids]
      result = json_from_summary(Summary.find_all_by_external_uid(params[:uids].split(",")))
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
