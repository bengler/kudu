require 'spec_helper'

describe Ack do

  let(:external_uid) {'post:#l0ngAndFiNeUId4U'}

  describe "create_or_update_summary" do

    it "creates a summary if none exists" do
      Ack.create!(:external_uid => external_uid, :identity => 123, :score => 1)
      ack = Ack.find_by_external_uid(external_uid)
      ack.should_not eq nil
      ack.score.should eq 1
      ack.summary.should_not eq nil
    end

    it "updates a summary if such exists" do
      summary = Summary.create!(:external_uid => external_uid)
      Ack.create!(:external_uid => external_uid, :identity => 123, :score => 1)
      ack = Ack.find_by_external_uid(external_uid)
      ack.should_not eq nil
      ack.score.should eq 1
      ack.summary.should_not eq nil
      ack.summary.should eq summary
    end

    it "updates a summary if an ack is destroyed" do
      ack = Ack.create!(:external_uid => external_uid, :identity => 123, :score => 1)
      ack.summary.positive_score.should eq 1
      ack.destroy
      summary = Summary.find_by_external_uid external_uid
      summary.positive_score.should eq 0
    end

  end
end