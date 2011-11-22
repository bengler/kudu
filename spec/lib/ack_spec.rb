require 'spec_helper'

describe Ack do

  let(:external_uid) {'post:$l0ngAndFiNeUId4U'}

  describe "create_or_update_item" do
    it "creates an item if none exists" do
      item = Item.create(:external_uid => external_uid)
      Ack.create!(:item=>item, :identity => 123, :score => 1)
      ack = Ack.find_by_item_id(item.id)
      ack.should_not eq nil
      ack.score.should eq 1
      ack.item.should_not eq nil
    end

    it "updates a item if such exists" do
      item = Item.create!(:external_uid => external_uid)
      Ack.create!(:item => item, :identity => 123, :score => 1)
      ack = Ack.find_by_item_id(item.id)
      ack.should_not eq nil
      ack.score.should eq 1
      ack.item.should_not eq nil
      ack.item.should eq item
    end

    it "updates a item if an ack is destroyed" do
      item = Item.create(:external_uid => external_uid)
      ack = Ack.create!(:item => item, :identity => 123, :score => 1)
      ack.item.positive_score.should eq 1
      ack.destroy
      item = Item.find_by_external_uid external_uid
      item.positive_score.should eq 0
    end

  end
end
