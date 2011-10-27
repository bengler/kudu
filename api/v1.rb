# encoding: utf-8
require "json"

class KuduV1 < Sinatra::Base
  
  helpers do

    def logger
      Log
    end

    def find_or_create(post_uid, identity)
      begin
        return Ack.find_by_post_uid_and_identity(post_uid, identity)
      rescue ActiveRecord::RecordNotFound => error
        return Ack.new(:uid => id_or_uid)
      end
    end

    def create_or_update(post_uid, identity)
      ack = find_or_create(post_uid, identity)
      halt 404 unless ack

      yield(Ack)

      response.status = ack.new_record? ? 201 : 200
      ack.save!
      ack.to_json
    end

  end

  error ActiveRecord::RecordNotFound do
    halt 404
  end

  error ActiveRecord::RecordInvalid do
    halt 412, 'Something went amiss while messing with an Ack'
  end


  get '/ack/recent' do
    limit = params[:limit] || 10
    Ack.recent(limit).to_json
  end

  # create or update a single Ack
  post '/ack' do
    halt 500, "missing params" unless (params[:post] && params[:score] && params[:identity])
    create_or_update(params[:post], params[:identity]) do |ack|
      ack.score = params[:score]
      ack.collection = params[:collection]
    end
  end

  # delete a single Ack
  delete '/ack' do
    halt 400, "missing params" unless (params[:post] && params[:identity])
    Ack.destroy(:post_uid => params[:post], :identity => params[:identity])
    response.status = 204
  end

  # query for Acks, this probably needs pagination
  get '/ack' do
    result = []
    if params[:collection]
      result = Ack.where(:collection => params[:collection]).to_json
    elsif params[:post]
      result = Ack.find_by_post_uid(params[:post])
    elsif params[:posts]
      result = Ack.find_all_by_post_uid(params[:posts])
    end
    response.status = 200
    result.to_json
  end


end
