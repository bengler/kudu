class Ack < ActiveRecord::Base

  belongs_to :score

  validates_presence_of :value, :identity

  scope :recent, lambda {|count| order("updated_at desc").limit(count)}

  scope :by_uid_and_kind, lambda { |uid, kind|
    joins(:score).where(:scores => {:external_uid => uid, :kind => kind})
  }

  after_update  :create_or_update_score, prepend: true
  after_create  :create_or_update_score, prepend: true
  after_destroy :create_or_update_score, prepend: true

  serialize :created_by_profile

  def create_or_update_score
    score.refresh_from_acks!
  end

  def uid
    klass = "ack"
    klass += ".#{score.kind}" if score.kind
    "#{klass}:#{score.path}$#{id}"
  end

  def attributes_for_export
    template = "api/v1/views/ack.pg"
    Petroglyph::Engine.new(File.read(template)).to_hash({:ack => self}, template)
  end
end
