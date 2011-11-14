require 'spec_helper'

describe Item do

  let(:external_uid) {'post:#l0ngAndFiNeUId4U'}
  let(:another_external_uid) {'post:#l0ngAndFiNeUId4Utoo'}

  it "calculates all items afresh" do
    item1 = Item.create!(:external_uid => external_uid)
    item2 = Item.create!(:external_uid => another_external_uid)
    Ack.create!(:item => item1, :identity => 1, :score => 1)
    Ack.create!(:item => item1, :identity => 2, :score => 1)
    Ack.create!(:item => item2, :identity => 1, :score => 1)
    Item.calculate_all
    Item.count.should eq 2
    Item.find_by_external_uid(external_uid).positive_score.should eq 2
  end

  describe "apply_score" do

    describe "calculates count, positive and negative" do
      before :each do
        Item.create!(:external_uid => external_uid)
      end

      it "gets a positive score right" do
        item = Item.find_by_external_uid(external_uid)
        item.apply_score(1)
        item.total_count.should eq 1
        item.positive_count.should eq 1
        item.negative_count.should eq 0
        item.neutral_count.should eq 0
        item.positive_score.should eq 1
        item.negative_score.should eq 0
        item.controversiality.should eq nil
      end

      it "gets a negative score right" do
        item = Item.find_by_external_uid(external_uid)
        item.apply_score(-1)
        item.total_count.should eq 1
        item.positive_count.should eq 0
        item.negative_count.should eq 1
        item.neutral_count.should eq 0
        item.positive_score.should eq 0
        item.negative_score.should eq 1
        item.controversiality.should eq nil
      end

      it "gets a zero score right" do
        item = Item.find_by_external_uid(external_uid)
        item.apply_score(0)
        item.total_count.should eq 1
        item.positive_count.should eq 0
        item.negative_count.should eq 0
        item.neutral_count.should eq 1
        item.positive_score.should eq 0
        item.negative_score.should eq 0
        item.controversiality.should eq nil
      end
    end

    describe "calculates controversiality" do
     it "is controversial" do
      item = Item.create!(:external_uid => external_uid,
                                :total_count => 200,
                                :positive_count => 99,
                                :negative_count => 100)
      item.apply_score 1
      item.controversiality.should == 1
     end

     it "is not controversial if everybody agrees" do
      item = Item.create!(:external_uid => external_uid,
                                :total_count => 100,
                                :positive_count => 100,
                                :negative_count => 0)
      item.apply_score 1
      item.controversiality.should == 0
     end

     it "is impossible to determine controversiality if less than a certain number of people have voted" do
      contro_limit = Item::CONTRO_LIMIT - 2
      item = Item.create!(:external_uid => external_uid,
                                :total_count => contro_limit-1,
                                :positive_count => contro_limit/2,
                                :negative_count => contro_limit/2)
      item.apply_score 0
      item.controversiality.should == nil
     end
   end
  end

end