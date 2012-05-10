require 'spec_helper'

describe Score do

  let(:external_uid) {'post:this.is.a.path.to$object_id'}

  it "extracts path from uid before save" do
    Score.create!(:external_uid => external_uid).path.should eq('this.is.a.path.to')
  end

  describe "scores" do

    subject { Score.new }

    describe "defaults" do
      its(:total_count) { should eq(0) }
      its(:positive_count) { should eq(0) }
      its(:neutral_count) { should eq(0) }
      its(:negative_count) { should eq(0) }
      its(:total_positive) { should eq(0) }
      its(:total_negative) { should eq(0) }
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
      its(:total_positive) { should eq(7) }
      its(:total_negative) { should eq(0) }
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
      its(:total_positive) { should eq(0) }
      its(:total_negative) { should eq(13) }
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
      its(:total_positive) { should eq(0) }
      its(:total_negative) { should eq(0) }
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
      its(:total_positive) { should eq(0) }
      its(:total_negative) { should eq(0) }
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
