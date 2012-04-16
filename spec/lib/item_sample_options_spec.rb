require 'item/sample_options'

describe ItemSampleOptions do

  let(:valid_segment) { {:field => 'valid_filter'} }
  let(:default_options) { {limit: "10", records: "100", path: 'a.b.c', shuffle: true, segments: [valid_segment], valid_filters: ['valid_filter']} }

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

  it "handles a string for limit" do
    ItemSampleOptions.new(default_options.merge(:limit => '13')).limit.should eq(13)
  end

  it "deprecates :shuffle in favor of randomize" do
    segment = ItemSampleOptions.new(default_options.merge(:shuffle => true, :randomize => false))
    segment.randomize.should be_false
  end

  describe "invalid parameters" do
    let(:minimal_options) { {:limit => 10, :segments => [valid_segment]} }

    it "complains about missing limit" do
      ->{ ItemSampleOptions.new(minimal_options.merge(:limit => nil)) }.should raise_error(ArgumentError)
    end

    it "complains about missing segments" do
      ->{ ItemSampleOptions.new(minimal_options.merge(:segments => nil)) }.should raise_error(ArgumentError)
    end

    it "complains about empty segments" do
      ->{ ItemSampleOptions.new(minimal_options.merge(:segments => [])) }.should raise_error(ArgumentError)
    end

    it "complains about invalid segments" do
      invalid_segment = {:field => 'invalid_filter'}
      ->{ ItemSampleOptions.new(minimal_options.merge(:segments => [invalid_segment])) }.should raise_error(ArgumentError)
    end
  end

  describe "comlicated truths" do
    ['true', 't', '1', 'y', true, 1].each do |truth|

      it "randomizes with #{truth.inspect} as true" do
        options = default_options.merge(:shuffle => truth, :include_own => truth, :identity_id => 12)
        subject = ItemSampleOptions.new(options)
        subject.randomize.should be_true
      end

      it "excludes votes with #{truth.inspect} as true" do
        options = default_options.merge(:shuffle => truth, :include_own => truth, :identity_id => 12)
        subject = ItemSampleOptions.new(options)
        subject.exclude_votes_by.should be_nil
      end
    end

    [false, nil, :whatever].each do |untruth|

      it "randomizes with #{untruth.inspect} as false" do
        options = default_options.merge(:shuffle => untruth, :include_own => untruth, :identity_id => 12)
        subject = ItemSampleOptions.new(options)
        subject.randomize.should be_false
      end

      it "excludes votes with #{untruth.inspect} as false" do
        options = default_options.merge(:shuffle => untruth, :include_own => untruth, :identity_id => 12)
        subject = ItemSampleOptions.new(options)
        subject.exclude_votes_by.should eq(12)
      end
    end
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
