class Score < ActiveRecord::Base
  include PebblePath

  has_many :acks

  validates_presence_of :kind, :external_uid
  
  after_initialize :initialize_histogram

  serialize :histogram

  scope :for_path, lambda { |path| by_path(path) }
  scope :order_by, lambda { |field, direction| order("#{field} #{direction} NULLS LAST") }
  scope :by_uid_and_kind, lambda { |uid, kind| where(:external_uid => uid, :kind => kind) }
  scope :exclude_votes_by, lambda { |identity|
    joins("LEFT OUTER JOIN acks on acks.score_id = scores.id and acks.identity=#{identity}").where("acks.id IS NULL")
  }
  scope :rank, lambda { |options|
    scope = scoped
    field = "total_count"

    if options[:by] == 'average'
      field = "((scores.positive - scores.negative)/(scores.total_count*1.0))"
      scope = scope.where("scores.total_count > 10")
    elsif columns.map(&:name).include?(options[:by].to_s)
      field =  options[:by]
    end
    direction = (options[:direction] || 'desc').to_s.downcase
    direction = 'desc' unless ['asc', 'desc'].include?(direction)
    scope.order("#{field} #{direction}").limit(options[:limit] || 10)
  }

  class << self
    def calculate_all
      Score.all.each do |score|
        score.refresh_from_acks!
      end
    end

    def pick(already_picked, resultset, number, random)
      picked = []
      until resultset.empty? || picked.size == number
        pos = random ? rand(resultset.length) : 0
        score = resultset.delete_at(pos)
        picked << score unless already_picked.include?(score.id)
      end
      picked
    end

    def by_field(options = {})
      scope = Score.scoped.for_path(options[:path]).order_by(options[:order_by], options[:direction]).limit(options[:limit])
      if options[:identity].present?
        scope = scope.exclude_votes_by(options[:identity])
      end
      scope
    end

    def valid_filters
      columns.map(&:name)
    end

    def combine_resultsets(params)
      records = Score.for_path(params[:path]).count
      segments = ScoreSampleOptions.new(params.merge(:records => records, :valid_filters => valid_filters)).segments

      picked = []
      remaining = []
      sampled = segments.map do |segment|

        results = Score.by_field(segment.query_parameters)
        sampled = Score.pick(picked, results, segment.share_of_results, segment.randomize)

        picked |= sampled.map(&:id)
        remaining.concat results

        sampled
      end
      sampled.flatten!

      diff = (params[:limit].to_i - sampled.size).to_i
      if diff > 0
        sampled |= Score.pick(picked, remaining, diff, params[:shuffle])
      end
      sampled.shuffle! if params[:shuffle]
      sampled
    end
  end

  def refresh_from_acks!
    self.reset
    self.acks.all.each do |ack|
      self.apply_score(ack.value)
    end
    self.save!
  end

  def reset
    self.total_count = 0
    self.positive_count = 0
    self.negative_count = 0
    self.neutral_count = 0
    self.positive = 0
    self.negative = 0
    self.controversiality = 0
    self.histogram = {}
  end

  def average
    return 0 if total_count == 0
    (positive - negative).to_f / total_count
  end

  def apply_score(score)
    self.histogram[score] ||= 0
    self.histogram[score] += 1
    self.total_count += 1
    if score > 0
      self.positive_count += 1
    elsif score < 0
      self.negative_count += 1
    else
      self.neutral_count += 1
    end
    self.positive += score if score > 0
    self.negative -= score if score < 0
    self.controversiality = [self.positive_count, self.negative_count].min
  end

  def controversiality
    if read_attribute(:controversiality) == 0
      write_attribute(:controversiality, [positive_count, negative_count].min)
    end
    read_attribute(:controversiality)
  end

  def external_uid=(uid)
    write_attribute(:external_uid, uid)
    klass, self.path, oid = Pebblebed::Uid.parse external_uid
  end

  private
  def initialize_histogram
    self.histogram ||= {}
  end
end
