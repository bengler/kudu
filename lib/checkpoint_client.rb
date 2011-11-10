class CheckpointClient

  def self.identity_from_session(host, checkpoint_session)
    pebbles = Pebbles::Connector.new(checkpoint_session, :host => host)
    res = pebbles['checkpoint'].get '/identities/me', {}
    res.identity
  end

end

