class Item < ActiveRecord::Base

  has_many :acks

  before_save :extract_path
  after_initialize :initialize_histogram

  serialize :histogram

  scope :for_path, lambda { |path| where(:path => path) }
  scope :order_by, lambda { |field, direction| order("#{field} #{direction} NULLS LAST") }
  scope :exclude_votes_by, lambda { |identity|
    joins("LEFT OUTER JOIN acks on acks.item_id = items.id and acks.identity=#{identity}").where("acks.id IS NULL")
  }

  class << self
    def calculate_all
      Item.all.each do |item|
        item.refresh_from_acks!
      end
    end

    def pick(already_picked, resultset, number, random)
      picked = []
      until resultset.empty? || picked.size == number
        pos = random ? rand(resultset.length) : 0
        item = resultset.delete_at(pos)
        picked << item unless already_picked.include?(item.id)
      end
      picked
    end

    def by_field(options = {})
      scope = Item.scoped.for_path(options[:path]).order_by(options[:order_by], options[:direction]).limit(options[:limit])
      if options[:identity].present?
        scope = scope.exclude_votes_by(options[:identity])
      end
      scope
    end

    def valid_filters
      columns.map(&:name)
    end

    def combine_resultsets(params)
      records = Item.for_path(params[:path]).count
      segments = ItemSampleOptions.new(params.merge(:records => records, :valid_filters => valid_filters)).segments

      picked = []
      remaining = []
      sampled = segments.map do |segment|

        results = Item.by_field(segment.query_parameters)
        sampled = Item.pick(picked, results, segment.share_of_results, segment.randomize)

        picked |= sampled.map(&:id)
        remaining.concat results

        sampled
      end
      sampled.flatten!

      diff = (params[:limit].to_i - sampled.size).to_i
      if diff > 0
        sampled |= Item.pick(picked, remaining, diff, params[:shuffle])
      end
      sampled.shuffle! if params[:shuffle]
      sampled
    end
  end

  def refresh_from_acks!
    self.reset
    self.acks.all.each do |ack|
      self.apply_score(ack.score)
    end
    self.save!
  end

  def reset
    self.total_count = 0
    self.positive_count = 0
    self.negative_count = 0
    self.neutral_count = 0
    self.positive_score = 0
    self.negative_score = 0
    self.controversiality = 0
    self.histogram = {}
  end

  def average_score
    return 0 if total_count == 0
    total_score / total_count
  end

  def total_score
    positive_score - negative_score / total_count
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
    self.positive_score += score if score > 0
    self.negative_score -= score if score < 0
    self.controversiality = [self.positive_count, self.negative_count].min
  end

  def controversiality
    if read_attribute(:controversiality) == 0
      write_attribute(:controversiality, [positive_count, negative_count].min)
    end
    read_attribute(:controversiality)
  end

  private
  def extract_path
    klass, self.path, oid = Pebblebed::Uid.parse external_uid
  end

  def initialize_histogram
    self.histogram ||= {}
  end
end
