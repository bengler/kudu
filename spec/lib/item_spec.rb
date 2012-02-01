require 'spec_helper'

describe Item do

  let(:external_uid) {'post:$l0ngAndFiNeUId4U'}
  let(:another_external_uid) {'post:$l0ngAndFiNeUId4Utoo'}
  let(:external_uid_with_path) {'post:this.is.a.path.to$object_id'}

  describe "extract_path_from_uid" do
    it "extracts path from uid before save" do
      item1 = Item.create!(:external_uid => external_uid_with_path)
      item1.path.should == 'this.is.a.path.to'
    end
    it "extracts  from uid before save" do
      item1 = Item.create!(:external_uid => external_uid_with_path)
    end
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
      end
    end

    describe "calculates controversiality" do
     it "define controversiality as the minimum value of positive_count or negative_count" do
      item = Item.create!(:external_uid => external_uid,
                                :positive_count => 100,
                                :negative_count => 40)

      item.apply_score 1
      item.controversiality.should eq 40

      100.times { item.apply_score -1}

      item.controversiality.should eq 101

     end
     it "is not controversial if everyone agrees" do
      item = Item.create!(:external_uid => external_uid,
                                :positive_count => 100,
                                :negative_count => 0)
      item.apply_score 1
      item.controversiality.should eq 0
     end

     it "is controversial if half of the voters agrees and the other half disagrees" do
      item = Item.create!(:external_uid => external_uid,
                                :positive_count => 50,
                                :negative_count => 50)
      item.apply_score 1
      item.controversiality.should eq 50
     end
   end
  end

end
