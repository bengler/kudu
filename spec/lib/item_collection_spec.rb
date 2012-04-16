require 'spec_helper'

def create_items
  Item.create!(external_uid: 'a:b.c$1', total_count: 10, controversiality: 8)
  Item.create!(external_uid: 'a:b.c$2', total_count: 9)
  Item.create!(external_uid: 'a:b.c$5', total_count: 6, controversiality: 7)
  Item.create!(external_uid: 'a:b.c$9', total_count: 2, controversiality: 6)

  Item.create!(external_uid: 'a:b.c$3', total_count: 8, controversiality: 2)
  Item.create!(external_uid: 'a:b.c$4', total_count: 7, controversiality: 1)
  Item.create!(external_uid: 'a:b.c$8', total_count: 3, controversiality: 5)
  Item.create!(external_uid: 'a:b.c$7', total_count: 4, controversiality: 4)
  Item.create!(external_uid: 'a:b.c$6', total_count: 5, controversiality: 3)
  Item.create!(external_uid: 'a:b.c$10', total_count: 1)
end

describe Item do
  before(:each) do
    create_items
  end

  it "selects active items" do
    params = {
      :limit => 8,
      :shuffle => false,
      :include_own => false,
      :segments => [
        {
          field: 'total_count',
          order: 'desc',
          percent: 50
        }
      ],
      :identity_id => nil,
      :path => 'b.c'
    }
    expected = ["a:b.c$1", "a:b.c$2", "a:b.c$3", "a:b.c$4", "a:b.c$5", "a:b.c$6", "a:b.c$7", "a:b.c$8"]
    Item.combine_resultsets(params).map(&:external_uid).should eq(expected)
  end

  it "selects controversial results" do
    params = {
      :limit => 8,
      :shuffle => false,
      :include_own => false,
      :segments => [
        {
          field: 'controversiality',
          order: 'desc',
          percent: 100
        }
      ],
      :identity_id => nil,
      :path => 'b.c'
    }
    expected = ["a:b.c$1", "a:b.c$5", "a:b.c$9", "a:b.c$8", "a:b.c$7", "a:b.c$6", "a:b.c$3", "a:b.c$4"]
    Item.combine_resultsets(params).map(&:external_uid).should eq(expected)
  end

  it "selects half-half" do
    params = {
      :limit => 8,
      :shuffle => false,
      :include_own => false,
      :segments => [
        {
          field: 'total_count',
          order: 'desc',
          percent: 50
        },
        {
          field: 'controversiality',
          order: 'desc',
          percent: 50
        }
      ],
      :identity_id => nil,
      :path => 'b.c'
    }
    expected = ["a:b.c$1", "a:b.c$2", "a:b.c$3", "a:b.c$4", "a:b.c$5", "a:b.c$9", "a:b.c$8", "a:b.c$7"]
    Item.combine_resultsets(params).map(&:external_uid).should eq(expected)
  end

  it "selects what it can (half-half)" do
    params = {
      :limit => 4,
      :shuffle => false,
      :include_own => false,
      :segments => [
        {
          field: 'total_count',
          order: 'desc',
          percent: 50,
          sample_size: 20
        },
        {
          field: 'controversiality',
          order: 'desc',
          percent: 50,
          sample_size: 20
        }
      ],
      :identity_id => nil,
      :path => 'b.c'
    }
    expected = ["a:b.c$1", "a:b.c$2", "a:b.c$5", "a:b.c$9"]
    Item.combine_resultsets(params).map(&:external_uid).should eq(expected)
  end

  it "selects what it can" do
    params = {
      :limit => 20,
      :shuffle => false,
      :include_own => false,
      :segments => [
        {
          field: 'total_count',
          order: 'desc',
          percent: 50
        },
        {
          field: 'controversiality',
          order: 'desc',
          percent: 50
        }
      ],
      :identity_id => nil,
      :path => 'b.c'
    }
    expected = ["a:b.c$1", "a:b.c$2", "a:b.c$3", "a:b.c$4", "a:b.c$5", "a:b.c$6", "a:b.c$7", "a:b.c$8", "a:b.c$9", "a:b.c$10"]
    Item.combine_resultsets(params).map(&:external_uid).should eq(expected)
  end

end
