require 'spec_helper'

describe 'API v1' do
  include Rack::Test::Methods

  def app
    KuduV1
  end

  it "is true" do
    1.should eq(1)
  end

  let(:post_uid) {'l0ngAndFiNeUId4U'}
  let(:another_post_uid) {'l0ngAndFiNeUId4Utoo'}
  let(:collection) {'lifeloop:oa:bursdag'}
  let(:identity) { 1337 }
  let(:another_identity) { 1338 }

  context 'GET /ack' do

    it 'finds acks in collection' do
      Ack.create!(:post_uid => post_uid, :identity => identity, :collection => collection)
      Ack.create!(:post_uid => post_uid, :identity => another_identity, :collection => collection)
      get "/ack?collection=#{collection}"
      result = JSON.parse(last_response.body)
      result["ack"]["post_uid"].should eq post_uid
    end

    it 'finds matching ack for post_uid' do
      Ack.create!(:post_uid => post_uid, :identity => identity)
      get "/ack?post=#{post_uid}"
      result = JSON.parse(last_response.body)
      result["ack"]["post_uid"].should eq post_uid
    end

    it 'finds matching acks for post_uids' do
      Ack.create!(:post_uid => post_uid, :identity => identity)
      Ack.create!(:post_uid => another_post_uid, :identity => identity)
      get "/ack?posts=#{post_uid},#{another_post_uid},nonexistinguid"
      result = JSON.parse(last_response.body)
      result.count.should eq 2
      #TODO: test if uids are present
    end

    it 'yields a 404 on a nonexistant photo' do
      get '/photos?post=nonexistinguid'
      last_response.status.should eq(404)
    end

  end

end
