require 'spec_helper'

describe 'API v1' do
  include Rack::Test::Methods

  def app
    KuduV1
  end

  let(:identity) { 1337 }

  let(:external_uid) {'post:$l0ngAndFiNeUId4U'}
  let(:an_score) { Score.create!(:external_uid => external_uid) }
  let(:an_ack) { Ack.create!(:score => an_score, :identity => identity, :value => 1) }

  let(:another_external_uid) {'post:$l0ngAndFiNeUId4Utoo'}
  let(:another_score) { Score.create!(:external_uid => another_external_uid) }
  let(:another_ack) { Ack.create!(:score => another_score, :identity => identity, :value => 1) }

  let(:unwanted_score) { Score.create!(:external_uid => "post:$unwanted_ack") }
  let(:unwanted_ack) { Ack.create!(:score => unwanted_score, :identity => identity, :value => 1) }

  context "with an identity" do
    let(:a_session) { {:session => "1234"} }

    before :each do
      Pebblebed::Connector.any_instance.stub(:checkpoint).and_return(DeepStruct.wrap(:me => {:id => identity, :god => false, :realm => 'safariman'}))
    end

    describe 'GET /acks/:uid' do
      it 'returns an ack for an uid given by current identity' do
        an_ack
        get "/acks/#{an_score.external_uid}", a_session
        last_response.status.should eq 200
        ack_response = JSON.parse(last_response.body)["acks"]
        ack_response[0]['ack']['id'].should eq an_ack.id
      end

      it 'updates an existing score and recalculates it' do
        an_ack
        put "/acks/#{external_uid}", a_session.merge(:ack => {:value => 0})
        last_response.status.should eq 200
        ack_response = JSON.parse(last_response.body)["ack"]
        Ack.find_by_id(ack_response['id']).value.should eq(0)
        score = Score.find_by_external_uid(external_uid)
        score.total_count.should eq(1)
        score.total_positive.should eq(0)
      end
    end

    describe 'POST /acks/:uid' do
      it 'creates an ack and a score' do
        post "/acks/#{external_uid}", a_session.merge(:ack => {:value => "+1"})
        last_response.status.should eq 201
        ack_response = JSON.parse(last_response.body)["ack"]
        Ack.find_by_id(ack_response['id']).value.should eq(1)
        Score.find_by_external_uid(external_uid).total_count.should eq(1)
      end

      it 'updates an existing score and recalculates it' do
        an_ack
        put "/acks/#{external_uid}", a_session.merge(:ack => {:value => 0})
        last_response.status.should eq 200
        ack_response = JSON.parse(last_response.body)["ack"]
        Ack.find_by_id(ack_response['id']).value.should eq(0)
        score = Score.find_by_external_uid(external_uid)
        score.total_count.should eq(1)
        score.total_positive.should eq(0)
      end
    end

    describe 'DELETE /acks/:uid' do
      it 'deletes an ack' do
        an_ack

        delete "/acks/#{external_uid}", a_session
        last_response.status.should eq(204)

        Ack.find_by_id(an_ack.id).should be_nil
      end
    end
  end

  context "without an identity" do
    before :each do
      Pebblebed::Connector.any_instance.stub(:checkpoint).and_return(DeepStruct.wrap(:me => {}))
    end

    describe "GET /scores/:uids" do
      it 'gets a score of acks for a single external_uid' do
        an_ack

        get "/scores/#{external_uid}"
        scores = JSON.parse(last_response.body)["scores"]
        scores.first["score"]["external_uid"].should eq(external_uid)
      end

      it 'gets scores of acks for a list of external_uids' do
        an_ack
        another_ack
        unwanted_ack

        get "/scores/#{external_uid},#{another_external_uid}"
        scores = JSON.parse(last_response.body)["scores"]
        scores.size.should eq(2)
        scores.first["score"]["external_uid"].should eq(external_uid)
        scores.last["score"]["external_uid"].should eq(another_external_uid)
      end
    end

    describe "has no access to protected endpoints" do
      protected_endpoints = [
        {:method => :post, :endpoint => "/acks/a$uid"},
        {:method => :delete, :endpoint => "/acks/a$uid"},
      ]

      protected_endpoints.each do |forbidden|
        it "fails to authorize #{forbidden[:endpoint]}" do
          self.send(forbidden[:method], forbidden[:endpoint])
          last_response.status.should eq(403)
        end
      end
    end
  end

  it "logs" do
    get "/log/something"
  end

end
