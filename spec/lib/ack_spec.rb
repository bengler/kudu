require 'spec_helper'

describe Ack do

  let(:external_uid) {'l0ngAndFiNeUId4U'}

  describe "create_or_update_summary" do
    it "creates a summary if none exists" do
      Ack.create!(:external_uid => external_uid, :identity => 123, :score => 1)
      ack = Ack.find_by_external_uid(external_uid)
      ack.should_not eq nil
      ack.score.should eq 1
      ack.summary.should_not eq nil
    end

    it "updates a summary if such exists" do
      summary = Summary.find_or_create_by_external_uid(external_uid)
      Ack.create!(:external_uid => external_uid, :identity => 123, :score => 1)
      ack = Ack.find_by_external_uid(external_uid)
      ack.should_not eq nil
      ack.score.should eq 1
      ack.summary.should_not eq nil
      ack.summary.external_uid.should eq summary.external_uid
    end
  end

  describe "delete ack" do
    it "keeps the summary up to date" do
      ack = Ack.create!(:external_uid => external_uid, :identity => 123, :score => 1)
      summary = ack.summary
      summary.should_not eq nil
      ack.destroy
      summary = Summary.find_by_external_uid(external_uid)
      summary.should_not eq nil
      summary.total_ack_count.should == 0
      summary.positive_ack_count.should == 0
      summary.negative_ack_count.should == 0
      summary.neutral_ack_count.should == 0
      summary.positive_score.should == 0
      summary.calculate_controversiality.should == nil
    end

    it "it looses controversiality when ack count drops below the limit" do
      contro_limit = Summary::CONTRO_LIMIT
      (contro_limit+1).times do |i|
        Ack.create!(:external_uid => external_uid, :identity => 123+i, :score => 1)
      end
      summary = Summary.find_by_external_uid(external_uid)
      summary.acks.count.should eq contro_limit+1
      summary.total_ack_count.should eq contro_limit+1
      summary.calculate_controversiality.should == 0
      summary.acks.last.destroy
      summary = Summary.find_by_external_uid(external_uid)
      summary.acks.count.should eq contro_limit
      summary.total_ack_count.should eq contro_limit
      summary.calculate_controversiality.should == nil
    end
  end

end