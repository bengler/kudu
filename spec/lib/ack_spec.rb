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
      ack.summary.count.should eq 1
    end

    it "updates a summary if such exists" do
      Summary.create!(:external_uid => external_uid, :count => 1)
      Ack.create!(:external_uid => external_uid, :identity => 123, :score => 1)
      ack = Ack.find_by_external_uid(external_uid)
      ack.should_not eq nil
      ack.score.should eq 1
      ack.summary.should_not eq nil
      ack.summary.count.should eq 2
    end


  end
end