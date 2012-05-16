class KuduV1 < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/score.rb'
  end

  # TODO: Implement pagination
  get '/scores/:uids/:kind' do |uid, kind|
    strategy = Pebblebed::UIDQuery.new(uid)
    if strategy.list?
      uids = uid.split(",")

      scores = Score.where(:kind => kind).find_all_by_external_uid(uids)
      by_uid = Hash[scores.map { |score| [score.external_uid, score] }]
      scores = uids.map { |uid| by_uid[uid] }

      pg :scores, :locals => {:scores => scores}
    elsif strategy.wildcard?
      klass, path, oid = Pebblebed::Uid.parse(uid)
      scores = Score.where(:kind => kind).by_path(path)      
      scores = scores.rank(:by => params[:rank]) if params[:rank]
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
    klass, path, oid = Pebblebed::Uid.parse(uid)
    scores = Score.where(:kind => kind).rank(:by => rank_by, :path => path, :limit => params[:limit], :direction => params[:direction])
    pg :scores, :locals => {:scores => scores}
  end

  get '/scores/:path/:kind/sample' do |path, kind|
    # Todo: actually take kind into consideration 
    identity_id = current_identity.id if current_identity
    scores = Score.combine_resultsets(params.merge(:path => path, :identity_id => identity_id)).flatten
    pg :scores, :locals => {:scores => scores}
  end
end
