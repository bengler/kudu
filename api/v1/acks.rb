#
# Note: acks returned from endpoints are by default scoped to the current identity.
# I.e. there are currently no way to get someone else's ack for an uid
#
class KuduV1 < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/kudu/ack.rb'
  end

  # Get current identity's ack for an uid/kind

  # @apidoc
  # Get a single ack for a uid, kind and current identity.
  #
  # @note Will fail without a current identity. Kind is typically "votes", "downloads", "likes" etc.
  # @category Kudu/Acks
  # @path /acks/:uid/:kind
  # @http GET
  # @example /api/kudu/v1/acks/post:acme.myapp.some.doc$1/votes
  # @required [String] uid UID denoting a resource.
  # @required [String] kind Kind.
  # @status 200 JSON
  get '/acks/:uid/:kind' do |uid, kind|
    require_identity
    ack = Ack.by_uid_and_kind(uid, kind).where(:identity => current_identity.id).first
    pg :ack, :locals => {:ack => ack}
  end

  # @apidoc
  # Create a single ack for current identity and the specified kind. Updates the ack if it exists.
  #
  # @note Will fail without a current identity. Kind is typically "votes", "downloads", "likes" etc.
  # @category Kudu/Acks
  # @path /acks/:uid/:kind
  # @http POST
  # @example /api/kudu/v1/acks/post:acme.myapp.some.doc$1/votes
  # @required [String] uid UID denoting a resource.
  # @required [String] kind Kind.
  # @required [Integer] value The value of the ack.
  # @status 201 JSON if created
  # @status 200 JSON if updated
  post '/acks/:uid/:kind' do |uid, kind|
    save_ack(uid, kind)
  end

  # @apidoc
  # Update a single ack for current identity and the specified kind.
  #
  # @note Will fail without a current identity. Kind is typically "votes", "downloads", "likes" etc.
  # @category Kudu/Acks
  # @path /acks/:uid/:kind
  # @http PUT
  # @example /api/kudu/v1/acks/post:acme.myapp.some.doc$1/votes
  # @required [String] uid UID denoting a resource.
  # @required [String] kind Kind.
  # @status 404 JSON if ack not found
  # @status 200 JSON if updated
  put '/acks/:uid/:kind' do |uid, kind|
    save_ack(uid, kind, :only_updates => true)
  end

  # Delete a single ack for current identity
  # @apidoc
  # Delete a single ack for current identity and the specified kind.
  #
  # @note Will fail without a current identity. Kind is typically "votes", "downloads", "likes" etc.
  # @category Kudu/Acks
  # @path /acks/:uid/:kind
  # @http DELETE
  # @example /api/kudu/v1/acks/post:acme.myapp.some.doc$1/votes
  # @required [String] uid UID denoting a resource.
  # @required [String] kind Kind.
  # @status 404 JSON if ack not found
  # @status 200 JSON if deleted
  delete '/acks/:uid/:kind' do |uid, kind|
    require_identity
    ack = Ack.by_uid_and_kind(uid, kind).where(:identity => current_identity.id).first
    halt 404, "Not found" unless ack

    ack.destroy
    pg :ack, :locals => {:ack => ack}
  end


  def save_ack(uid, kind, options = {})
    require_identity

    param_ack = params[:ack]

    halt 500, "Missing ack object in post body." if param_ack.nil?

    value = param_ack['value']

    halt 500, "Invalid value #{value.inspect}." unless value and Integer(value)

    score = Score.by_uid_and_kind(uid, kind).first
    score ||= Score.create!(:external_uid => uid, :kind => kind) unless options[:only_updates]

    halt 404, "Score with uid \"#{uid}\" of kind \"#{kind}\"not found." unless score

    ack = Ack.find_by_score_id_and_identity(score.id, current_identity.id)
    ack ||= Ack.new(:score_id => score.id, :identity => current_identity.id) unless options[:only_updates]

    halt 404, "Ack for \"#{uid}\" with kind \"#{kind}\" by identity ##{current_identity.id} not found." unless ack

    ip = request.env['HTTP_X_FORWARDED_FOR'] || request.ip
    ip = ip.sub("::ffff:", "") # strip away ipv6 compatible formatting
    ack.ip = ip.split(/,\s*/).uniq.first  # HTTP_X_FORWARDED_FOR may contain multiple comma separated ips

    response.status = 201 if ack.new_record?
    ack.value = value
    ack.save!
    pg :ack, :locals => {:ack => ack}
  end

end
