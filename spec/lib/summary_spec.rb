require 'spec_helper'

describe Summary do

  let(:external_uid) {'l0ngAndFiNeUId4U'}
  let(:another_external_uid) {'l0ngAndFiNeUId4Utoo'}
  let(:collection) {'lifeloop:oa:bursdag'}

  describe "apply_score!" do

    describe "calculates count, positive and negative" do
      before :each do
        Summary.create!(:external_uid => external_uid)
      end

      it "gets a positive score right" do
        summary = Summary.find_by_external_uid(external_uid)
        summary.apply_score!(1)
        summary.total_ack_count.should eq 1
        summary.positive_ack_count.should eq 1
        summary.negative_ack_count.should eq 0
        summary.neutral_ack_count.should eq 0
        summary.positive_score.should eq 1
        summary.negative_score.should eq 0
        summary.controversiality.should eq nil
      end

      it "gets a negative score right" do
        summary = Summary.find_by_external_uid(external_uid)
        summary.apply_score!(-1)
        summary.total_ack_count.should eq 1
        summary.positive_ack_count.should eq 0
        summary.negative_ack_count.should eq 1
        summary.neutral_ack_count.should eq 0
        summary.positive_score.should eq 0
        summary.negative_score.should eq 1
        summary.controversiality.should eq nil
      end

      it "gets a zero score right" do
        summary = Summary.find_by_external_uid(external_uid)
        summary.apply_score!(0)
        summary.total_ack_count.should eq 1
        summary.positive_ack_count.should eq 0
        summary.negative_ack_count.should eq 0
        summary.neutral_ack_count.should eq 1
        summary.positive_score.should eq 0
        summary.negative_score.should eq 0
        summary.controversiality.should eq nil
      end
    end

    describe "calculates controversiality" do
     it "is controversial" do
      summary = Summary.create!(:external_uid => external_uid,
                                :total_ack_count => 200,
                                :positive_ack_count => 99,
                                :negative_ack_count => 100)
      summary.apply_score! 1
      summary.controversiality.should == 1
     end
   end
  end

  describe "rollback_score!" do

    it "gets a positive score right" do
      summary = Summary.create!(:external_uid => external_uid, 
                                :total_ack_count => 1,
                                :positive_ack_count => 1,
                                :negative_ack_count => 0,
                                :neutral_ack_count => 0,
                                :positive_score => 1,
                                :negative_score => 0)
      summary.rollback_score!(1)
      summary.total_ack_count.should eq 0
      summary.positive_ack_count.should eq 0
      summary.negative_ack_count.should eq 0
      summary.neutral_ack_count.should eq 0
      summary.positive_score.should eq 0
      summary.negative_score.should eq 0
      summary.controversiality.should eq nil
    end

    it "gets a negative score right" do
      summary = Summary.create!(:external_uid => external_uid, 
                                :total_ack_count => 1,
                                :positive_ack_count => 0,
                                :negative_ack_count => 1,
                                :neutral_ack_count => 0,
                                :positive_score => 0,
                                :negative_score => 1)
      summary.rollback_score!(-1)
      summary.total_ack_count.should eq 0
      summary.positive_ack_count.should eq 0
      summary.negative_ack_count.should eq 0
      summary.neutral_ack_count.should eq 0
      summary.positive_score.should eq 0
      summary.negative_score.should eq 0
      summary.controversiality.should eq nil
    end

    it "gets a zero score right" do
      summary = Summary.create!(:external_uid => external_uid, 
                                :total_ack_count => 1,
                                :positive_ack_count => 0,
                                :negative_ack_count => 0,
                                :neutral_ack_count => 1,
                                :positive_score => 0,
                                :negative_score => 0)
      summary.rollback_score!(0)
      summary.total_ack_count.should eq 0
      summary.positive_ack_count.should eq 0
      summary.negative_ack_count.should eq 0
      summary.neutral_ack_count.should eq 0
      summary.positive_score.should eq 0
      summary.negative_score.should eq 0
      summary.controversiality.should eq nil
    end

  end
end