require 'spec_helper'

describe 'API v1' do
  include Rack::Test::Methods

  def app
    KuduV1
  end

  let(:external_uid) {'post:#l0ngAndFiNeUId4U'}
  let(:another_external_uid) {'post:#l0ngAndFiNeUId4Utoo'}
  let(:identity) { 1337 }
  let(:another_identity) { 1338 }

  let(:positive_ack_request_body_hash) {
    { "score" => "+1",
      "session" => "1234"}
  }
  let(:delete_ack_request_body_hash) { {"session" => "1234"} }


  context 'POST /ack/:uid' do

    before :each do
      KuduV1.any_instance.stub(:verified_identity).and_return(DeepStruct.wrap(:id=>1337))
    end

    it 'creates an ack and a summary' do
      post "/ack/#{CGI.escape(external_uid)}", positive_ack_request_body_hash
      ack = Ack.find_by_external_uid(external_uid)
      ack.should_not eq nil
      ack.score.should eq 1
      ack.summary.should_not eq nil
    end

    it 'updates an existing summary and recalculates it' do
      Ack.create!(:external_uid => external_uid, :identity => identity, :score => 0)
      post "/ack/#{CGI.escape(external_uid)}", positive_ack_request_body_hash
      summary = Summary.find_by_external_uid(external_uid)
      summary.should_not eq nil
      summary.total_ack_count.should eq 1
      summary.positive_score.should eq 1
    end

    it 'deletes an ack' do
      Ack.create!(:external_uid => external_uid, :identity => identity, :score => 1)
      delete "/ack/#{CGI.escape(external_uid)}", delete_ack_request_body_hash
      Ack.find_by_external_uid(external_uid).should eq nil
    end

    it 'gets a summary of acks for a single external_uid' do
      Ack.create!(:external_uid => external_uid, :identity => identity, :score => 1)
      get "/summary?uid=#{CGI.escape(external_uid)}"
      result = JSON.parse(last_response.body)
      result["results"].first["summary"]["external_uid"].should eq external_uid
    end

    it 'gets summaries of acks for a list of external_uids' do
      Ack.create!(:external_uid => external_uid, :identity => identity, :score => 1)
      Ack.create!(:external_uid => another_external_uid, :identity => identity, :score => 1)
      Ack.create!(:external_uid => "unwanted_ack", :identity => identity, :score => 1)
      get "/summary?uids=#{CGI.escape(external_uid)},#{CGI.escape(another_external_uid)}"
      result = JSON.parse(last_response.body)
      result["results"].count.should eq 2
      result["results"].first["summary"]["external_uid"].should eq external_uid
      result["results"].second["summary"]["external_uid"].should eq another_external_uid
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
        post "/ack/#{CGI.escape(external_uid)}", positive_ack_request_body_hash
        last_response.status.should eq 403
      end
    end

    it "fails with 403 forbidden unless it got a valid session" do
      VCR.use_cassette('fails_if_invalid_user') do
        env = {
          'HTTP_X_FORWARDED_HOST' => "checkpoint.dev",
          :cookie => 'checkpoint.session=1nv@l1d535510nk3y'
        }
        post "/ack/#{CGI.escape(external_uid)}", positive_ack_request_body_hash, env
        last_response.status.should eq 403
      end
    end

    it "is all good if session key is valid" do
      VCR.use_cassette('returns_valid_user') do
        env = {
          'HTTP_X_FORWARDED_HOST' => "checkpoint.dev",
          :cookie => 'checkpoint.session=v@l1d535510nk3y'
        }
        post "/ack/#{CGI.escape(external_uid)}", positive_ack_request_body_hash, env
        last_response.status.should eq 201
      end
    end

  end

end
