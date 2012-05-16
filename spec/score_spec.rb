require 'spec_helper'

describe Score do

  let(:external_uid) {'post:this.is.a.path.to$object_id'}

  it "extracts path from uid before save" do
    Score.create!(:external_uid => external_uid, :kind => 'kudos').path.to_s.should eq('this.is.a.path.to')
  end

  describe "#rank" do
    let(:base_uid) { "xyz:a.b.c." }
    before(:each) do
      11.times do |i|
        Score.create!(:external_uid => "#{base_uid}#{i}", :kind => 'points', :total_count => (10-i), :positive => i, :negative => -i*i)
      end
      Score.create!(:external_uid => "#{base_uid}12", :kind => 'stars', :total_count => 40, :positive => 1000)
    end

    it "fetches the top 10 by default" do
      results = Score.rank(:kind => 'points', :by => 'positive', :path => 'a.b.c.*')
      results.size.should eq(10)
      points = results.map(&:positive)
      points.should eq(points.sort.reverse)
    end

    it "can fetch off a different column" do
      results = Score.rank(:kind => 'points', :by => 'total_count', :path => 'a.b.c.*')
      results.size.should eq(10)
      points = results.map(&:total_count)
      points.should eq(points.sort.reverse)
    end

    it "takes an arbitrary limit" do
      results = Score.rank(:kind => 'points', :by => 'total_count', :path => 'a.b.c.*', :limit => 3)
      results.size.should eq(3)
      points = results.map(&:total_count)
      points.should eq(points.sort.reverse)
    end

    it "can change the direction" do
      results = Score.rank(:kind => 'points', :by => 'total_count', :path => 'a.b.c.*', :direction => 'asc')
      results.size.should eq(10)
      points = results.map(&:total_count)
      points.should eq(points.sort)
    end

    it "can rank by 'average'" do
      results = Score.rank(:kind => 'points', :by => 'average', :path => 'a.b.c.*', :direction => 'desc', :limit => 12)
      points = results.map(&:average)
      points.first.should eq 90.0
      points.last.should eq 0.0
      points.should eq points.sort.reverse
      
    end

    it "paginates, too"
  end

  describe "scores" do

    subject { Score.new }

    describe "defaults" do
      its(:total_count) { should eq(0) }
      its(:positive_count) { should eq(0) }
      its(:neutral_count) { should eq(0) }
      its(:negative_count) { should eq(0) }
      its(:positive) { should eq(0) }
      its(:negative) { should eq(0) }
      its(:average) { should eq(0) }
      its(:histogram) { should eq({}) }
    end

    describe "vote up" do
      before(:each) do
        subject.apply_score(7)
      end

      its(:total_count) { should eq(1) }
      its(:positive_count) { should eq(1) }
      its(:neutral_count) { should eq(0) }
      its(:negative_count) { should eq(0) }
      its(:positive) { should eq(7) }
      its(:negative) { should eq(0) }
      its(:average) { should eq(7) }
      its(:histogram) { should eq({7 => 1}) }
    end

    describe "vote down" do
      before(:each) do
        subject.apply_score(-13)
      end

      its(:total_count) { should eq(1) }
      its(:positive_count) { should eq(0) }
      its(:neutral_count) { should eq(0) }
      its(:negative_count) { should eq(1) }
      its(:positive) { should eq(0) }
      its(:negative) { should eq(13) }
      its(:average) { should eq(-13) }
      its(:histogram) { should eq({-13 => 1}) }
    end

    describe "vote meh" do
      before(:each) do
        subject.apply_score(0)
      end

      its(:total_count) { should eq(1) }
      its(:positive_count) { should eq(0) }
      its(:neutral_count) { should eq(1) }
      its(:negative_count) { should eq(0) }
      its(:positive) { should eq(0) }
      its(:negative) { should eq(0) }
      its(:average) { should eq(0) }
      its(:histogram) { should eq({0 => 1}) }
    end

    describe "#reset" do
      before(:each) do
        subject.apply_score(9)
        subject.apply_score(-21)
        subject.reset
      end

      its(:total_count) { should eq(0) }
      its(:positive_count) { should eq(0) }
      its(:neutral_count) { should eq(0) }
      its(:negative_count) { should eq(0) }
      its(:positive) { should eq(0) }
      its(:negative) { should eq(0) }
      its(:controversiality) { should eq(0) }
      its(:histogram) { should eq({}) }
    end

    describe "controversiality" do
      it "corresponds to the minority of haters" do
        Score.new(:positive_count => 100, :negative_count => 40).controversiality.should eq(40)
      end

      it "corresponds to a minority of fans" do
        Score.new(:positive_count => 10, :negative_count => 40).controversiality.should eq(10)
      end

      it "isn't controversial if everyone agrees" do
        Score.new(:positive_count => 100, :negative_count => 0).controversiality.should eq(0)
      end

      it "is controversial if the split is even" do
        Score.new(:positive_count => 30, :negative_count => 30).controversiality.should eq(30)
      end
    end
  end

end
