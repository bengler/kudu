class KuduV1 < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/score.rb'
  end

  # Create a score in order to preserve creation date.
  # This is idempotent.
  # FIXME: There are no tests for this code.
  put '/scores/:uid/touch' do |uid|
    require_identity
    score = Score.find_or_create_by_external_uid(uid)

    halt 204
  end

  # TODO: Implement pagination
  get '/scores/:uids' do
    uids = params[:uids].split(",")
    scores = Score.find_all_by_external_uid(uids)
    pg :scores, :locals => {:scores => scores}
  end

  get '/scores/:path/sample' do |path|
    identity_id = current_identity.id if current_identity
    scores = Score.combine_resultsets(params.merge(:path => path, :identity_id => identity_id)).flatten
    pg :scores, :locals => {:scores => scores}
  end

  
end