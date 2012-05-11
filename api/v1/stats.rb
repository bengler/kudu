class KuduV1 < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
  end

  # DEPRECATED. Rewrite when DittForslag is done.
  get '/acks/:uid/:kind/stats' do |uid, kind|
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
  
  # FIXME: Hack for dittforslag.
  # It (incorrectly) returns the count of all acks for given kind in the system, not just for dittforslag.
  get '/acks/:uid/:kind/count' do |uid, kind|
    {:uid => uid, :count => Ack.joins(:score).where(:scores => {:kind => kind}).count,
      :note => "Not fully implemented! Returns the full ack count for all realms and paths always."}.to_json
  end
end