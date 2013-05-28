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
  # @example /api/kudu/v1/scores/post:acme.myapp.stuff.*/downloads?rank=positive&direction=desc
  # @required [String] uid UID denoting a resource, or a wildcard UID indicating a collection of resources.
  # @required [String] kind Kind to count.
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

  # Get all acks for an uid of given kind
  get '/scores/:uid/:kind/acks' do |uid, kind|
    acks, pagination = limit_offset_collection(Ack.by_uid_and_kind(uid, kind), :limit => params['limit'], :offset => params['offset'])
    response.status = 200

    unless has_access_to_path?(Pebbles::Uid.new(uid).path)
      acks.each do |ack|
        ack.ip = '[protected]'
      end
    end
    pg :acks, :locals => {:acks => acks, :pagination => pagination}
  end

  # Delete an ack by id
  delete '/scores/:uid/:kind/acks/:id' do |uid, kind, id|
    require_action_allowed(:delete, uid)
    ack = Ack.find(id)
    ack.delete
    pg :ack, :locals => {:ack => ack}
  end

  # @apidoc
  # Create a score.
  #
  # @description Create a score, i.e. in order to preserve creation date. This is idempotent. Subsequent posts to the same URL will not have any effect.
  #
  # @note Kind is typically "votes", "downloads", "likes" etc.
  # @category Kudu/Scores
  # @path /scores/:uid/:kind/touch
  # @http POST
  # @example /api/kudu/v1/scores/post:acme.myapp.stuff.*/downloads/touch
  # @required [String] uid UID denoting a resource, or a wildcard UID indicating a collection of resources.
  # @required [String] kind Kind to count.
  # @status 201 JSON
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

  # @apidoc
  # Get a mix of scores for resources on a path.
  #
  # @description Mix is a sample of score fields, e.g. "positive", "controversial" etc
  # @note Kind isn't taken into consideration. Kind would typically be "votes", "downloads", "likes" etc.
  # @category Kudu/Scores
  # @path /api/kudu/v1/scores/:path/:kind/sample
  # @http GET
  # @example /api/kudu/v1/scores/acme.myapp.stuff/downloads/sample?limit=10&randomize=true&segments[][field]=controversiality&segments[][percent]=40&segments[][order]=desc&segments[][field]=created_at&segments[][percent]=60&segments[][order]=desc
  # @required [String] path Path to resources.
  # @required [String] kind Kind to count.
  # @required [String] segments A list of fields to fetch scores from. See example.
  # @required [Integer] limit Maximum number of results.
  # @optional [Boolean] shuffle Set to true in order to randomize samples.
  # @status 200 JSON
  get '/scores/:path/:kind/sample' do |path, kind|
    # TODO: kind should be taken into consideration
    identity_id = current_identity.id if current_identity
    scores = Score.combine_resultsets(params.merge(:path => path, :identity_id => identity_id)).flatten
    pg :scores, :locals => {:scores => scores}
  end
end
