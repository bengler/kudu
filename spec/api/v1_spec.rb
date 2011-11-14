require 'spec_helper'
require 'vcr'

describe 'API v1' do
  include Rack::Test::Methods

  def app
    KuduV1
  end

  let(:external_uid) {'post:#l0ngAndFiNeUId4U'}
  let(:another_external_uid) {'post:#l0ngAndFiNeUId4Utoo'}
  let(:identity) { 1337 }
  let(:another_identity) { 1338 }

  let(:positive_request_body_hash) {
    { "score" => "+1",
      "session" => "1234"}
  }
  let(:delete_request_body_hash) { {"session" => "1234"} }


  context 'POST /acks/:uid' do

    before :each do
      KuduV1.any_instance.stub(:require_identity).and_return(DeepStruct.wrap(:id=>1337))
    end

    it 'creates an ack and a item' do
      post "/acks/#{CGI.escape(external_uid)}", positive_request_body_hash
      item = Item.find_by_external_uid(external_uid)
      item.should_not eq nil
      ack = Ack.find_by_item_id(item.id)
      ack.should_not eq nil
      ack.score.should eq 1
      ack.item.should_not eq nil
    end

    it 'updates an existing item and recalculates it' do
      item = Item.create!(:external_uid => external_uid)
      Ack.create!(:item => item, :identity => identity, :score => 0)
      post "/acks/#{CGI.escape(external_uid)}", positive_request_body_hash
      item = Item.find_by_external_uid(external_uid)
      item.should_not eq nil
      item.total_count.should eq 1
      item.positive_score.should eq 1
    end

    it 'deletes an ack' do
      item = Item.create!(:external_uid => external_uid)
      Ack.create!(:item => item, :identity => identity, :score => 1)
      delete "/acks/#{CGI.escape(external_uid)}", delete_request_body_hash
      Ack.find_by_item_id(item.id).should eq nil
    end

    it 'gets a item of acks for a single external_uid' do
      item = Item.create!(:external_uid => external_uid)
      Ack.create!(:item => item, :identity => identity, :score => 1)
      get "/items/#{CGI.escape(external_uid)}"
      result = JSON.parse(last_response.body)
      result["results"].first["item"]["external_uid"].should eq external_uid
    end

    it 'gets items of acks for a list of external_uids' do
      item = Item.create!(:external_uid => external_uid)
      item_another = Item.create!(:external_uid => another_external_uid)
      item_unwanted = Item.create!(:external_uid => "unwanted_ack")
      Ack.create!(:item=>item, :identity => identity, :score => 1)
      Ack.create!(:item=>item_another, :identity => identity, :score => 1)
      Ack.create!(:item=>item_unwanted, :identity => identity, :score => 1)
      get "/items/#{CGI.escape(external_uid)},#{CGI.escape(another_external_uid)}"
      result = JSON.parse(last_response.body)
      result["results"].count.should eq 2
      result["results"].first["item"]["external_uid"].should eq external_uid
      result["results"].second["item"]["external_uid"].should eq another_external_uid
    end

  end

  it "logs" do
    get "/log/something"
  end


  describe "verified_identity" do

    before(:each) do
      VCR.config do |c|
        c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
        c.stub_with :webmock
      end
    end

    it "fails 403 forbidden unless request contains valid session info" do
      VCR.use_cassette('fail_if_no_session') do
        post "/acks/#{CGI.escape(external_uid)}", positive_request_body_hash
        last_response.status.should eq 403
      end
    end

    it "fails with 403 forbidden unless it got a valid session" do
      VCR.use_cassette('fails_if_invalid_user') do
        env = {
          'HTTP_X_FORWARDED_HOST' => "checkpoint.dev",
          :cookie => 'checkpoint.session=1nv@l1d535510nk3y'
        }
        post "/acks/#{CGI.escape(external_uid)}", positive_request_body_hash, env
        last_response.status.should eq 403
      end
    end

    it "is all good if session key is valid" do
      VCR.use_cassette('returns_valid_user') do
        env = {
          'HTTP_X_FORWARDED_HOST' => "checkpoint.dev",
          :cookie => 'checkpoint.session=v@l1d535510nk3y'
        }
        post "/acks/#{CGI.escape(external_uid)}", positive_request_body_hash, env
        last_response.status.should eq 201
      end
    end

  end

end
