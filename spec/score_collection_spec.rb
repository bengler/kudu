require 'spec_helper'

def create_scores
  Score.create!(external_uid: 'a:b.c$1', :kind => 'kudos', total_count: 10, controversiality: 8)
  Score.create!(external_uid: 'a:b.c$2', :kind => 'kudos', total_count: 9)
  Score.create!(external_uid: 'a:b.c$5', :kind => 'kudos', total_count: 6, controversiality: 7)
  Score.create!(external_uid: 'a:b.c$9', :kind => 'kudos', total_count: 2, controversiality: 6)

  Score.create!(external_uid: 'a:b.c$3', :kind => 'kudos', total_count: 8, controversiality: 2)
  Score.create!(external_uid: 'a:b.c$4', :kind => 'kudos', total_count: 7, controversiality: 1)
  Score.create!(external_uid: 'a:b.c$8', :kind => 'kudos', total_count: 3, controversiality: 5)
  Score.create!(external_uid: 'a:b.c$7', :kind => 'kudos', total_count: 4, controversiality: 4)
  Score.create!(external_uid: 'a:b.c$6', :kind => 'kudos', total_count: 5, controversiality: 3)
  Score.create!(external_uid: 'a:b.c$10', :kind => 'kudos', total_count: 1)
end

describe Score do
  before(:each) do
    create_scores
  end

  it "selects active scores" do
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
    Score.combine_resultsets(params).map(&:external_uid).should eq(expected)
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
    Score.combine_resultsets(params).map(&:external_uid).should eq(expected)
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
    Score.combine_resultsets(params).map(&:external_uid).should eq(expected)
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
    Score.combine_resultsets(params).map(&:external_uid).should eq(expected)
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
    Score.combine_resultsets(params).map(&:external_uid).should eq(expected)
  end

  it "shuffles selections" do
    params = {
      :limit => 4,
      "shuffle" => true,
      "random_seed" => 4, # pass seed in order to get same test result every time
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

    results = []
    5.times do
      results << Score.combine_resultsets(params).map(&:external_uid)
    end

    results.uniq.size.should eq(5)
  end


end
