class KuduV1 < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/ack.rb'
  end
  
  # Get Acks for score(s) for  current identity
  get '/acks/:uids' do |uids|
    require_identity
    uids = params[:uids].split(",")
    scores = Score.find_all_by_external_uid(uids)
    acks = Ack.find_all_by_score_id(scores, current_identity.id)
    response.status = 200
    pg :acks, :locals => {:acks => acks}
  end

  # Create a single Ack for current identity
  post '/acks/:uid' do |uid|
    require_identity

    ack = params[:ack]

    halt 500, "Missing ack object in post body" if ack.nil?
    halt 500, "Invalid value #{ack['value'].inspect}" unless ack['value'] and Integer(ack['value'])
    score = Score.find_or_create_by_external_uid(uid)
    ack = Ack.create_or_update(score, current_identity.id, :value => ack['value'])
    ack.save!
    response.status = 201
    pg :ack, :locals => {:ack => ack}
  end

  # FIXME: Hack for dittforslag.
  # It (incorrectly) returns the count of all acks in the system, not just for dittforslag.
  get '/acks/:uid/count' do |uid|
    {:uid => uid, :count => Ack.count,
      :note => "Not fully implemented! Returns the full ack count for all realms and paths always."}.to_json
  end

  # Update a single Ack for the current identity
  put '/acks/:uid' do |uid|
    require_identity

    ack = params[:ack]

    halt 500, "Invalid value #{ack['value'].to_s}" unless ack['value'] and Integer(ack['value'])
    score = Score.find_or_create_by_external_uid(uid)
    ack = Ack.create_or_update(score, current_identity.id, :value => ack['value'])
    ack.save!
    pg :ack, :locals => {:ack => ack}
  end

  # Delete a single Ack
  delete '/acks/:uid' do |uid|
    require_identity

    score = Score.find_by_external_uid(uid)
    ack = Ack.find_by_score_id(score.id, current_identity.id)
    ack.destroy
    response.status = 204
  end

  # DEPRECATED. Delete when DittForslag is done.
  get '/acks/:uid/stats' do |uid|
    total = Ack.count
    positive = Ack.where("value > 0").count
    negative = Ack.where("value < 0").count
    unique_voters = Ack.select("distinct identity").count
    avg_votes_per_voter = total.to_f / unique_voters.to_f
    {
      :uid => uid,
      :positive_count => positive,
      :negative_count => negative,
      :total_count => total,
      :unique_voters => unique_voters,
      :avg_votes_per_voter => avg_votes_per_voter,
      :note => "Not fully implemented! Returns the full ack count for all realms and paths always."
    }.to_json
  end
  
end