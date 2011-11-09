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
    end

    it 'updates an existing ack and recalculates the summary' do
      Ack.create!(:external_uid => external_uid, :identity => identity, :score => 0)
      post "/ack/#{external_uid}", positive_ack_request_body_hash
      ack = Ack.find_by_external_uid(external_uid)
      ack.should_not eq nil
      ack.score.should eq 1
      ack.summary.should_not eq nil
    end

    it 'deletes an ack' do
      Ack.create!(:external_uid => external_uid, :identity => identity, :score => 1)
      delete "/ack/#{external_uid}", delete_ack_request_body_hash
      Ack.find_by_external_uid(external_uid).should eq nil
    end

    it 'gets a summary of acks for a single external_uid' do
      Ack.create!(:external_uid => external_uid, :identity => identity, :score => 1)
      get "/summary?uid=#{external_uid}"
      result = JSON.parse(last_response.body)
      result["results"].first["summary"]["external_uid"].should eq external_uid
    end

    it 'gets summaries of acks for a list of external_uids' do
      Ack.create!(:external_uid => external_uid, :identity => identity, :score => 1)
      Ack.create!(:external_uid => another_external_uid, :identity => identity, :score => 1)
      Ack.create!(:external_uid => "unwanted_ack", :identity => identity, :score => 1)
      get "/summary?uids=#{external_uid},#{another_external_uid}"
      result = JSON.parse(last_response.body)
      result["results"].count.should eq 2
      result["results"].first["summary"]["external_uid"].should eq external_uid
      result["results"].second["summary"]["external_uid"].should eq another_external_uid
    end

  end

end
