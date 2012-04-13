require 'item/segment'

describe Segment do
  let(:default_options) do
    {
      limit: 10,
      records: 1000,
      path: 'a.b.c',
      randomize: true,
      valid_filters: ['valid_filter'],
      exclude_votes_by: nil,
      field: 'valid_filter',
    }
  end

  describe "defaults" do
    subject { Segment.new(default_options) }

    its(:final_limit) { should eq(10) }
    its(:path) { should eq('a.b.c') }
    its(:randomize) { should be_true }
    its(:order_by) { should eq('valid_filter') }
    its(:direction) { should eq('desc') }
    its(:percent_of_source) { should eq(100) }
    its(:percent_of_results) { should eq(100) }
    its(:share_of_source) { should eq(1000) }
    its(:share_of_results) { should eq(10) }
    its(:limit) { should eq(1000) }
    its(:exclude_votes_by) { should be_nil }
    its(:valid?) { should be_true }

    its(:query_parameters) { should eq(path: 'a.b.c', limit: 1000, order_by: 'valid_filter', direction: 'desc', exclude_votes_by: nil) }
  end

  context "when invalid" do
    subject { Segment.new(default_options.merge(:field => 'invalid_filter')) }

    its(:valid?) { should be_false }
  end

  describe "invalid parameters" do
    ['asc', 'desc'].each do |direction|
      it "accepts #{direction} as direction" do
        ->{ Segment.new(:order => direction) }.should_not raise_error(ArgumentError)
      end
    end

    it "complains about invalid direction" do
      ->{ Segment.new(:order => 'up') }.should raise_error(ArgumentError)
    end
  end

  it "deprecates :order in favor of :direction" do
    segment = Segment.new(default_options.merge(:direction => 'asc'))
    segment.direction.should eq('asc')
  end

  describe "#limit" do
    context "select from the total share of source records" do
      subject { Segment.new(default_options.merge(:records => 1000, :percent => 50)) }

      its(:final_limit) { should eq(10) }
      its(:share_of_source) { should eq(500) }

      its(:limit) { should eq(500) }

      context "if not randomizing" do
        subject { Segment.new(default_options.merge(records: 1000, percent: 50, randomize: false)) }

        its(:final_limit) { should eq(10) }
        its(:share_of_source) { should eq(10) }

        its(:limit) { should eq(10) }
      end
    end

    context "select from enough records to fill the final quota if share is smaller than final limit" do
      subject { Segment.new(default_options.merge(:records => 10, :percent => 50)) }

      its(:final_limit) { should eq(10) }
      its(:share_of_source) { should eq(5) }

      its(:limit) { should eq(10) }
    end
  end

  describe "quotas" do
    subject { Segment.new(default_options.merge(:percent => 10)) }

    specify "the percent of total records to select from" do
      subject.percent_of_source.should eq(10)
    end

    specify "the number of records to select from" do
      subject.share_of_source.should eq(100)
    end

    specify "percentage of result to allocate to this segment" do
      subject.percent_of_results.should eq(10)
    end

    specify "the share of the results to allocate to this segment" do
      subject.share_of_results.should eq(1)
    end

    context "with sample_size" do
      subject { Segment.new(default_options.merge(:percent => 10, :sample_size => 20)) }

      specify "sample_size (also in percentage) overrides percent" do
        subject.percent_of_source.should eq(20)
      end

      specify "sample_size does not influence allocation of results" do
        subject.percent_of_results.should eq(10)
      end
    end

    context "with funky numbers" do
      subject { Segment.new(default_options.merge(:percent => 13, :records => 117)) }

      its(:percent_of_source) { should eq(13) }
      its(:share_of_source) { should eq(16) }
      its(:percent_of_results) { should eq(13) }
      its(:share_of_results) { should eq(2) }
    end
  end

  context "with strings" do
    subject { Segment.new(default_options.merge(:percent => '28.1', :sample_size => '81.2')) }

    its(:percent_of_source) { should eq(81.2) }
    its(:percent_of_results) { should eq(28.1) }
  end
end
