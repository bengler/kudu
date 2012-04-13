class Segment

  attr_reader :order_by, :direction, :path, :final_limit, :records, :randomize, :valid_filters,
    :percent_of_source, :share_of_source, :percent_of_results, :share_of_results, :exclude_votes_by
  def initialize(options = {})
    @final_limit = options[:limit]
    @records = options[:records]
    @path = options[:path]
    @randomize = options[:randomize]
    @order_by = options[:field]
    @direction = options[:order] || 'desc'
    @percent_of_source = options[:sample_size] || options[:percent] || default_percentage
    @percent_of_results = options[:percent] || default_percentage
    @exclude_votes_by = options[:exclude_votes_by]
    @valid_filters = options[:valid_filters] || []
  end

  def valid?
    valid_filters.include? order_by
  end

  def limit
    [final_limit, share_of_source].max
  end

  def share_of_source
    @share_of_source ||= randomize ? (percent_of_source * 0.01 * records).ceil : final_limit
  end

  def share_of_results
    @share_of_results ||= (percent_of_results * 0.01 * final_limit).ceil
  end

  private
  def default_percentage
    100
  end
end
