require 'spec_helper'

describe Summary do

  let(:external_uid) {'l0ngAndFiNeUId4U'}
  let(:another_external_uid) {'l0ngAndFiNeUId4Utoo'}
  let(:collection) {'lifeloop:oa:bursdag'}

  describe "find_by_external_uid" do
    it "returns nil if a summary does not exists for the given external uid" do
      Summary.find_by_external_uid("n0n3x1st@ntu1d").should eq nil
    end
  end

  describe "find_or_create_by_external_uid" do
    it "returns nil if a summary does not exists for the given external uid" do
      Summary.find_or_create_by_external_uid("n0n3x1st@ntu1d").should_not eq nil
    end
  end

  describe "apply_score" do

    describe "calculates count, positive and negative" do
      let(:summary) {Summary.new(:external_uid => external_uid)}

      it "gets a positive score right" do
        summary.apply_score(1)
        summary.total_ack_count.should eq 1
        summary.positive_ack_count.should eq 1
        summary.negative_ack_count.should eq 0
        summary.neutral_ack_count.should eq 0
        summary.positive_score.should eq 1
        summary.negative_score.should eq 0
        summary.controversiality.should eq nil
      end

      it "gets a negative score right" do
        summary.apply_score(-1)
        summary.total_ack_count.should eq 1
        summary.positive_ack_count.should eq 0
        summary.negative_ack_count.should eq 1
        summary.neutral_ack_count.should eq 0
        summary.positive_score.should eq 0
        summary.negative_score.should eq 1
        summary.controversiality.should eq nil
      end

      it "gets a zero score right" do
        summary.apply_score(0)
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
      summary = Summary.new(external_uid)
      summary.positive_ack_count = 100
      summary.negative_ack_count = 100
      summary.calculate_controversiality.should == 1.0
     end

     it "is not controversial if everybody agrees" do
      summary = Summary.new(external_uid)
      summary.positive_ack_count = 100
      summary.negative_ack_count = 0
      summary.calculate_controversiality.should == 0.0
     end

     it "is impossible to determine controversiality if less than a certain number of people have voted" do
      summary = Summary.new(external_uid)
      summary.positive_ack_count = (Summary::CONTRO_LIMIT / 2) -1
      summary.negative_ack_count = (Summary::CONTRO_LIMIT / 2) -1
      summary.calculate_controversiality.should == nil
     end
   end
  end
  describe "summarizes all acks" do
      it "recalculates summaries for all acks" do
      10.times do |i|
        Ack.create!(:external_uid => external_uid, :identity => 123+i, :score => 1)
      end
      Summary.calculate_all
      summary = Summary.find_by_external_uid external_uid
      summary.total_ack_count.should == 10
    end
  end
end