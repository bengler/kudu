#
# Note: acks returned from endpoints are by default scoped to the current identity.
# I.e. there are currently no way to get someone else's ack for an uid
#
class KuduV1 < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/ack.rb'
  end
  
  # Get current identity's ack for an uid/kind
  get '/acks/:uid/:kind' do |uid, kind|
    require_identity
    ack = Ack.by_uid_and_kind(uid, kind).where(:identity => current_identity.id).first
    pg :ack, :locals => {:ack => ack}
  end

  # Create a single ack for current identity
  # Responds with status code 201 and the saved ack if ack is successfully updated
  # Responds with status code 200 if the ack already existed and got updated
  post '/acks/:uid/:kind' do |uid, kind|
    save_ack(uid, kind)
  end

  # Update a single ack for the current identity
  # It will create a vote record for the ack if it doesnt already exist
  # Responds with status code 404 if vote or ack is not found
  # Responds with status code 200 and the updated ack if ack is successfully updated
  put '/acks/:uid/:kind' do |uid, kind|
    save_ack(uid, kind, :only_updates => true)
  end

  def save_ack(uid, kind, opts={})
    require_identity

    param_ack = params[:ack]
    value = param_ack['value']

    halt 500, "Missing ack object in post body." if param_ack.nil?
    halt 500, "Invalid value #{value.inspect}." unless value and Integer(value)

    score = Score.by_uid_and_kind(uid, kind).first
    score ||= Score.create!(:external_uid => uid, :kind => kind) unless opts[:only_updates]

    halt 404, "Score with uid \"#{uid}\" of kind \"#{kind}\"not found." unless score

    ack = Ack.find_by_score_id_and_identity(score.id, current_identity.id)
    ack ||= Ack.new(:score_id => score.id, :identity => current_identity.id) unless opts[:only_updates]
    ack.ip = request.ip

    halt 404, "Ack for \"#{uid}\" with kind \"#{kind}\" by identity ##{current_identity.id} not found." unless ack

    response.status = 201 if ack.new_record?
    ack.value = value
    ack.save!
    pg :ack, :locals => {:ack => ack}
  end

  # Delete a single ack for current identity
  delete '/acks/:uid/:kind' do |uid, kind|
    require_identity
    ack = Ack.by_uid_and_kind(uid, kind).where(:identity => current_identity.id).first
    halt 404, "Not found" unless ack

    ack.destroy
    pg :ack, :locals => {:ack => ack}
  end

end