# encoding: utf-8
require "json"

class KuduV1 < Sinatra::Base
  
  helpers do

    def logger
      Log
    end

    # put this in Summary and make it also handle array as input
    def json_from_summary(summary)
      result = {}
      result["results"] = [summary] || []
      result.to_json
    end

  end


  # create or update a single Ack
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



  # # query for Acks, this probably needs pagination
  # get '/ack' do
  #   result = []
  #   if params[:collection]
  #     result = Ack.where(:collection => params[:collection]).to_json
  #   elsif params[:post]
  #     result = Ack.find_all_by_post_uid(params[:post])
  #   elsif params[:posts]
  #     result = Ack.find_all_by_post_uid(params[:posts].split(","))
  #   end
  #   response.status = 200
  #   result.to_json
  # end

  private

  # TODO: implement this as it should be, using checkpoint goodness
  def identity_from_session
    1337
  end

end
