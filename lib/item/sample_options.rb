require 'item/segment'

class ItemSampleOptions

  attr_reader :exclude_votes_by, :records, :limit, :path, :randomize, :valid_filters, :raw_segments, :segments
  def initialize(options = {})
    raise ArgumentError.new('Please specify `limit`') unless options[:limit]

    @valid_filters = options[:valid_filters] || []
    @records = options[:records]
    @path = options[:path]
    @randomize = truth? options.fetch(:randomize) { options[:shuffle] }
    @limit = options[:limit].to_i
    @exclude_votes_by = options.fetch(:exclude_votes_by) { options[:identity_id] unless truth?(options[:include_own]) }
    @raw_segments = options[:segments] || []
    @segments = raw_segments.map do |options|
      Segment.new(attributes.merge(options))
    end.select { |segment| segment.valid? }

    raise ArgumentError.new('Please specify valid `segments`') if segments.empty?
  end

  def attributes
    [
      :limit, :path, :records, :randomize, :exclude_votes_by, :valid_filters
    ].inject({}) do |collection, attribute|
      collection[attribute] = send(attribute)
      collection
    end
  end

  def truth?(value)
    ['y', 't', '1', 'true', true, 1].include?(value)
  end
end
