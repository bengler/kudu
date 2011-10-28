require 'spec_helper'

describe 'API v1' do
  include Rack::Test::Methods

  def app
    KuduV1
  end

  it "is true" do
    1.should eq(1)
  end

  let(:external_uid) {'l0ngAndFiNeUId4U'}
  let(:another_external_uid) {'l0ngAndFiNeUId4Utoo'}
  let(:collection) {'lifeloop:oa:bursdag'}
  let(:identity) { 1337 }
  let(:another_identity) { 1338 }

  let(:positive_ack_request_body_hash) { 
    { "score" => "+1",
      "session" => "1234"}
  }
  let(:delete_ack_request_body_hash) { {"session" => "1234"} }


  context 'POST /ack/:uid' do

    it 'creates an ack and a summary' do
      post "/ack/#{external_uid}", positive_ack_request_body_hash
      ack = Ack.find_by_external_uid(external_uid)
      ack.should_not eq nil
      ack.score.should eq 1
      ack.summary.should_not eq nil
      ack.summary.count.should eq 1
    end

    it 'updates an existing ack and recalculates the summary' do
      Ack.create!(:external_uid => external_uid, :identity => identity, :score => 0)
      post "/ack/#{external_uid}", positive_ack_request_body_hash
      ack = Ack.find_by_external_uid(external_uid)
      ack.should_not eq nil
      ack.score.should eq 1
      ack.summary.should_not eq nil
      ack.summary.count.should eq 2
    end

    it 'deletes an ack' do
      Ack.create!(:external_uid => external_uid, :identity => identity, :score => 1)
      delete "/ack/#{external_uid}", delete_ack_request_body_hash
      Ack.find_by_external_uid(external_uid).should eq nil
    end


  end

  # context 'GET /ack' do

  #   it 'finds acks in collection' do
  #     Ack.create!(:post_uid => post_uid, :identity => identity, :collection => collection)
  #     Ack.create!(:post_uid => post_uid, :identity => another_identity, :collection => collection)
  #     get "/ack?collection=#{collection}"
  #     result = JSON.parse(last_response.body)
  #     result["ack"]["post_uid"].should eq post_uid
  #   end

  #   it 'finds matching ack for post_uid' do
  #     Ack.create!(:post_uid => post_uid, :identity => identity)
  #     get "/ack?post=#{post_uid}"
  #     result = JSON.parse(last_response.body)
  #     result["ack"]["post_uid"].should eq post_uid
  #   end

  #   it 'finds matching acks for post_uids' do
  #     Ack.create!(:post_uid => post_uid, :identity => identity)
  #     Ack.create!(:post_uid => another_post_uid, :identity => identity)
  #     get "/ack?posts=#{post_uid},#{another_post_uid},nonexistinguid"
  #     result = JSON.parse(last_response.body)
  #     result.count.should eq 2
  #     #TODO: test if uids are present
  #   end

  #   it 'yields a 404 on a nonexistant photo' do
  #     get '/photos?post=nonexistinguid'
  #     last_response.status.should eq(404)
  #   end

  # end

end
