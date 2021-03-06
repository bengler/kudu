require 'spec_helper'

describe Ack do

  let(:external_uid) {'post:a.b.c$l0ngAndFiNeUId4U'}
  let(:kind) {'kudos'}

  it "has a uid" do
    score = Score.new(:external_uid => external_uid)
    ack = Ack.new(:score => score)
    ack.stub(:id => 1)
    ack.uid.should eq('ack:a.b.c$1')
  end

  describe "create_or_update_score" do
    it "creates a score if none exists" do
      score = Score.create(:external_uid => external_uid, :kind => kind)
      Ack.create!(:score=>score, :identity => 123, :value => 1)
      ack = Ack.find_by_score_id(score.id)
      ack.should_not eq nil
      ack.value.should eq 1
      ack.score.should_not eq nil
    end

    it "updates a score if such exists" do
      score = Score.create!(:external_uid => external_uid, :kind => kind)
      Ack.create!(:score => score, :identity => 123, :value => 1)
      ack = Ack.find_by_score_id(score.id)
      ack.should_not eq nil
      ack.value.should eq 1
      ack.score.should_not eq nil
      ack.score.should eq score
    end

    it "updates a score if an ack is destroyed" do
      score = Score.create(:external_uid => external_uid, :kind => kind)
      ack = Ack.create!(:score => score, :identity => 123, :value => 1)
      ack.score.positive.should eq 1
      ack.destroy
      score = Score.find_by_external_uid external_uid
      score.positive.should eq 0
    end

  end
end
