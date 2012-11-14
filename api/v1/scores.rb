class KuduV1 < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/kudu/score.rb'
  end

  # @apidoc
  # Get detailed scores for resources with a specific kind.
  #
  # @note Kind is typically "votes", "downloads", "likes" etc.
  # @category Kudu/Scores
  # @path /api/kudu/v1/scores/:uid/:kind
  # @http GET
  # @example /api/kudu/v1/scores/post.track:apdm.bandwagon.west.firda.*/downloads?rank=positive&direction=desc
  # @required [String] uid UID denoting a resource, or a wildcard UID indicating a collection of resources.
  # @required [String] kind Action kind to count.
  # @optional [Integer] limit Maximum number of results. Defaults to 20.
  # @optional [Integer] offset Index of the first results. Defaults to 0.
  # @optional [String] rank Field to sort by. Available fields are "total_count", "positive_count", "negative_count", "neutral_count", "positive", "negative", "average", "controversiality", "histogram","positive_score", "negative_score", "average_score".
  # @optional [String] direction Sort order. Defaults to "desc".
  # @status 200 JSON
  get '/scores/:uid/:kind' do |uid, kind|
    query = Pebbles::Uid.query(uid)
    if query.list?
      uids = query.list
      scores = Score.where(:kind => kind).find_all_by_external_uid(uids)
      by_uid = Hash[scores.map { |score| [score.external_uid, score] }]
      scores = uids.map { |uid| by_uid[uid] }
      pg :scores, :locals => {:scores => scores}
    elsif query.collection?
      scores = Score.where(:kind => kind).by_path(query.path)
      scores = scores.rank(:by => params[:rank], :direction => params[:direction]) if params[:rank]
      scores, pagination = limit_offset_collection(scores, :limit => params['limit'], :offset => params['offset'])
      pg :scores, :locals => {:scores => scores, :pagination => pagination}
    else
      score = Score.by_uid_and_kind(uid, kind).first
      score ||= Score.new
      pg :score, :locals => {:score => score}
    end
  end

  # Create a score (i.e. in order to preserve creation date)
  # This is idempotent. Subsequent posts to the same url will not have any effect.
  post '/scores/:uid/:kind/touch' do |uid, kind|
    require_identity
    score = Score.by_uid_and_kind(uid, kind).first
    unless score
      score = Score.create!(:external_uid => uid, :kind => kind)
      response.status = 201
    end
    pg :score, :locals => {:score => score}
  end

  # Deprecated. Use :rank option to '/scores/:uids/:kind'
  get '/scores/:uid/:kind/rank/:by' do |uid, kind, rank_by|
    query =  Pebbles::Uid.query(uid)
    scores = Score.where(:kind => kind).rank(:by => rank_by, :path => query.path, :limit => params[:limit], :direction => params[:direction])
    pg :scores, :locals => {:scores => scores}
  end

  get '/scores/:path/:kind/sample' do |path, kind|
    # Todo: actually take kind into consideration
    identity_id = current_identity.id if current_identity
    scores = Score.combine_resultsets(params.merge(:path => path, :identity_id => identity_id)).flatten
    pg :scores, :locals => {:scores => scores}
  end
end
