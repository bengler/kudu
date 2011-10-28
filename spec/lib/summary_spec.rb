require 'spec_helper'

describe Summary do

  let(:external_uid) {'l0ngAndFiNeUId4U'}
  let(:another_external_uid) {'l0ngAndFiNeUId4Utoo'}
  let(:collection) {'lifeloop:oa:bursdag'}

  describe "apply_score!" do

    before :each do
      Summary.create!(:external_uid => external_uid)
    end
    
    it "gets a positive score right" do
      summary = Summary.find_by_external_uid(external_uid)
      summary.apply_score!(1)
      summary.count.should eq 1
      summary.positive.should eq 1
      summary.negative.should eq 0
    end

    it "gets a negative score right" do
      summary = Summary.find_by_external_uid(external_uid)
      summary.apply_score!(-1)
      summary.count.should eq 1
      summary.positive.should eq 0
      summary.negative.should eq 1
    end

    it "gets a zero score right" do
      summary = Summary.find_by_external_uid(external_uid)
      summary.apply_score!(0)
      summary.count.should eq 1
      summary.positive.should eq 0
      summary.negative.should eq 0
    end

  end

  describe "rollback_score!" do

    it "gets a positive score right" do
      summary = Summary.create!(:external_uid => external_uid, :count => 1, :positive => 1, :negative => 0)
      summary.rollback_score!(1)
      summary.count.should eq 0
      summary.positive.should eq 0
      summary.negative.should eq 0
    end

    it "gets a negative score right" do
      summary = Summary.create!(:external_uid => external_uid, :count => 1, :positive => 0, :negative => 1)
      summary.rollback_score!(-1)
      summary.count.should eq 0
      summary.positive.should eq 0
      summary.negative.should eq 0
    end

    it "gets a zero score right" do
      summary = Summary.create!(:external_uid => external_uid, :count => 1, :positive => 0, :negative => 0)
      summary.rollback_score!(0)
      summary.count.should eq 0
      summary.positive.should eq 0
      summary.negative.should eq 0
    end

  end
end