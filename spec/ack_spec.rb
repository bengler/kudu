require 'spec_helper'

describe Ack do

  let(:external_uid) {'post:$l0ngAndFiNeUId4U'}

  describe "create_or_update_score" do
    it "creates a score if none exists" do
      score = Score.create(:external_uid => external_uid)
      Ack.create!(:score=>score, :identity => 123, :value => 1)
      ack = Ack.find_by_score_id(score.id)
      ack.should_not eq nil
      ack.value.should eq 1
      ack.score.should_not eq nil
    end

    it "updates a score if such exists" do
      score = Score.create!(:external_uid => external_uid)
      Ack.create!(:score => score, :identity => 123, :value => 1)
      ack = Ack.find_by_score_id(score.id)
      ack.should_not eq nil
      ack.value.should eq 1
      ack.score.should_not eq nil
      ack.score.should eq score
    end

    it "updates a score if an ack is destroyed" do
      score = Score.create(:external_uid => external_uid)
      ack = Ack.create!(:score => score, :identity => 123, :value => 1)
      ack.score.total_positive.should eq 1
      ack.destroy
      score = Score.find_by_external_uid external_uid
      score.total_positive.should eq 0
    end

  end
end
