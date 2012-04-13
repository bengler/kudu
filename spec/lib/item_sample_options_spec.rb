require 'item/sample_options'

describe ItemSampleOptions do

  let(:valid_segment) { {:field => 'valid_filter'} }
  let(:default_options) { {limit: 10, records: 100, path: 'a.b.c', shuffle: true, segments: [valid_segment], valid_filters: ['valid_filter']} }

  describe "defaults" do
    subject { ItemSampleOptions.new(default_options.merge(:exclude_votes_by => 42)) }

    its(:limit) { should eq(10) }
    its(:records) { should eq(100) }
    its(:path) { should eq('a.b.c') }
    its(:randomize) { should be_true }
    its(:valid_filters) { should eq(['valid_filter']) }
    its(:exclude_votes_by) { should eq(42) }

    its(:attributes) { should eq(limit: 10, records: 100, path: 'a.b.c', randomize: true, exclude_votes_by: 42, valid_filters: ['valid_filter']) }
  end

  describe "comlicated truths" do
  end

  describe "identity" do

    it "excludes votes" do
      segment = ItemSampleOptions.new(default_options.merge(:exclude_votes_by => 42))
      segment.exclude_votes_by.should eq(42)
    end

    it "can't exclude votes without an identity id" do
      segment = ItemSampleOptions.new(default_options.merge(:exclude_votes_by => nil))
      segment.exclude_votes_by.should be_nil
    end

    it "ignores deprecated fields" do
      segment = ItemSampleOptions.new(default_options.merge(:identity_id => 1337, :include_own => false, :exclude_votes_by => nil))
      segment.exclude_votes_by.should be_nil
    end

    context "deprecated" do
      it "excludes votes" do
        segment = ItemSampleOptions.new(default_options.merge(:identity_id => 1337, :include_own => false))
        segment.exclude_votes_by.should eq(1337)
      end

      it "doesn't exclude votes" do
        segment = ItemSampleOptions.new(default_options.merge(:identity_id => 1337, :include_own => true))
        segment.exclude_votes_by.should be_nil
      end
    end
  end
end
