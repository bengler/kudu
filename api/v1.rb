# encoding: utf-8
require "json"

class KuduV1 < Sinatra::Base
  
  helpers do

    def logger
      Log
    end

    def find_or_create(post_uid, identity)
      begin
        return Kudo.find_by_post_uid_and_identity(post_uid, identity)
      rescue ActiveRecord::RecordNotFound => error
        return Kudo.new(:uid => id_or_uid)
      end
    end

    def create_or_update(post_uid, identity)
      kudo = find_or_create(post_uid, identity)
      halt 404 unless kudo

      yield(kudo)

      response.status = kudo.new_record? ? 201 : 200
      kudo.save!
      kudo.to_json
    end

  end

  error ActiveRecord::RecordNotFound do
    halt 404
  end

  error ActiveRecord::RecordInvalid do
    halt 412, 'Cannot create kudo without a valid :post_uid and :identity'
  end


  get '/ack/recent' do
    limit = params[:limit] || 10
    Kudo.recent(limit).to_json
  end

  # create or update a single kudo
  post '/ack' do
    halt 500, "missing params" unless (params[:post] && params[:score] && params[:identity])
    create_or_update(params[:post], params[:identity]) do |kudo|
      kudo.score = params[:score]
      kudo.collection = params[:collection]
    end
  end

  # delete a single kudo
  delete '/ack' do
    halt 400, "missing params" unless (params[:post] && params[:identity])
    Kudo.destroy(:post_uid => params[:post], :identity => params[:identity])
    response.status = 204
  end

  # query for kudos, this probably needs pagination
  get '/ack' do
    result = []
    if params[:collection]
      result = Kudo.where(:collection => params[:collection]).to_json
    elsif params[:post]
      result = Kudo.find_by_post_uid(params[:post])
    elsif params[:posts]
      result = Kudo.find_all_by_post_uid(params[:posts])
    end
    response.status = 200
    result.to_json
  end


end
