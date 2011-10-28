require 'spec_helper'

describe Summary do

  let(:external_uid) {'l0ngAndFiNeUId4U'}
  let(:another_external_uid) {'l0ngAndFiNeUId4Utoo'}
  let(:collection) {'lifeloop:oa:bursdag'}

  describe "recalculate" do
    
    it "gets a positive score right" do
      summary = Summary.create!(:external_uid => external_uid)
      summary.recalculate!(1)
      summary.count.should eq 1
      summary.positive.should eq 1
      summary.negative.should eq 0
    end

    it "gets a negative score right" do
      summary = Summary.create!(:external_uid => external_uid)
      summary.recalculate!(-1)
      summary.count.should eq 1
      summary.positive.should eq 0
      summary.negative.should eq 1
    end

  end
end