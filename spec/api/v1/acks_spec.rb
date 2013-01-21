require 'spec_helper'

describe 'API v1 acks' do
  include Rack::Test::Methods

  def app
    KuduV1
  end

  let(:identity) { 1337 }

  let(:external_uid) { 'post:realm.some.fine.realm$l0ngAndFiNeUId4U' }
  let(:a_score) { Score.create!(:external_uid => external_uid, :kind => 'kudos') }
  let(:an_ack) { Ack.create!(:score => a_score, :identity => identity, :value => 1) }

  before :each do
    Pebblebed::Connector.any_instance.stub(:checkpoint).and_return(stub(:get => alice))
  end

  let(:alice_profile) do
    {
      :provider => "twitter",
      :nickname => "alice",
      :name => "Alice Cooper",
      :profile_url => "http://twitter.com/RealAliceCooper",
      :image_url => "https://si0.twimg.com/profile_images/1281973459/twitter_profile.jpg",
      :description => "The ONLY Official Alice Cooper Twitter!"
    }
  end

  let(:alice) { DeepStruct.wrap(:identity => {:id => identity, :god => false, :realm => 'safariman'}, :profile => alice_profile)}
  let(:odin) { DeepStruct.wrap(:identity => {:id => 1, :god => true, :realm => 'safariman'}) }

  describe 'GET /acks/:uid' do
    it 'returns an ack' do
      an_ack
      get "/acks/#{an_ack.uid}"
      last_response.status.should eq 200
      ack_response = JSON.parse(last_response.body)
      ack_response['ack']['id'].should eq an_ack.id
      ack_response['ack']['kind'].should eq 'kudos'
    end
  end

  describe 'DELETE /acks/:uid' do
    context 'when god' do
      it 'deletes an ack' do
      end
    end

    context 'when current identity owns the ack' do
      it 'deletes the ack' do
      end
    end

    context 'when not own ack' do
      it "doesn't allow deletion" do
      end
    end
  end


  context "with an identity" do
    let(:a_session) { {:session => "1234"} }

    describe 'GET /acks/:uid/kind' do
      it 'returns an ack for an :uid of :kind given by current identity' do
        an_ack
        get "/acks/#{a_score.external_uid}/kudos", a_session
        last_response.status.should eq 200
        ack_response = JSON.parse(last_response.body)
        ack_response['ack']['id'].should eq an_ack.id
        ack_response['ack']['kind'].should eq 'kudos'
      end
    end

    describe 'PUT /acks/:uid/:kind' do
      it 'updates an existing score and recalculates it' do
        an_ack
        put "/acks/#{external_uid}/kudos", a_session.merge(:ack => {:value => 0})
        last_response.status.should eq 200
        ack_response = JSON.parse(last_response.body)["ack"]
        Ack.find_by_id(ack_response['id']).value.should eq(0)
        score = Score.find_by_external_uid(external_uid)
        score.total_count.should eq(1)
        score.positive.should eq(0)
      end
    end

    describe 'POST /acks/:uid/:kind' do
      it 'creates an ack and a score' do
        post "/acks/#{external_uid}/kudos", a_session.merge(:ack => {:value => "+1"})
        last_response.status.should eq 201
        ack_response = JSON.parse(last_response.body)["ack"]
        ack = Ack.find_by_id(ack_response['id'])
        ack.value.should eq(1)
        ack.ip.should eq('127.0.0.1')
        Score.find_by_external_uid(external_uid).total_count.should eq(1)
      end

      it "stores a copy of the identity's checkpoint profile" do
        post "/acks/#{external_uid}/kudos", a_session.merge(:ack => {:value => 1})
        last_response.status.should eq 201
        ack_response = JSON.parse(last_response.body)["ack"]
        ack = Ack.find_by_id(ack_response['id'])
        ack.value.should eq(1)
        ack.created_by_profile.should eq(alice.profile.unwrap)
        Score.find_by_external_uid(external_uid).total_count.should eq(1)
      end

      it "stores nothing as profile for users without a profile" do
        Pebblebed::Connector.any_instance.stub(:checkpoint).and_return(stub(:get => DeepStruct.wrap(:identity => {:id => identity, :god => false, :realm => 'safariman'})))
        post "/acks/#{external_uid}/kudos", a_session.merge(:ack => {:value => 1})
        last_response.status.should eq 201
        ack_response = JSON.parse(last_response.body)["ack"]
        ack = Ack.find_by_id(ack_response['id'])
        ack.created_by_profile.should eq(nil)
        Score.find_by_external_uid(external_uid).total_count.should eq(1)
      end
    end

    describe 'PUT /acks/:uid/:kind' do
      it 'updates an existing score and recalculates it' do
        an_ack
        put "/acks/#{external_uid}/kudos", a_session.merge(:ack => {:value => 0})
        last_response.status.should eq 200
        ack_response = JSON.parse(last_response.body)["ack"]
        Ack.find_by_id(ack_response['id']).value.should eq(0)
        score = Score.find_by_external_uid(external_uid)
        score.total_count.should eq(1)
        score.positive.should eq(0)
      end
    end

    describe 'DELETE /acks/:uid/:kind' do
      it 'deletes an ack' do
        an_ack

        delete "/acks/#{external_uid}/kudos", a_session
        last_response.status.should eq(204)

        Ack.find_by_id(an_ack.id).should be_nil
      end
    end
  end

  context "without an identity" do
    let(:alice) { DeepStruct.wrap(:identity => {}) }

    describe "has no access to protected endpoints" do
      protected_endpoints = [
        {:method => :post, :endpoint => "/acks/:kind/a$uid"},
        {:method => :delete, :endpoint => "/acks/:kind/a$uid"},
      ]

      protected_endpoints.each do |forbidden|
        it "fails to authorize #{forbidden[:endpoint]}" do
          self.send(forbidden[:method], forbidden[:endpoint])
          last_response.status.should eq(403)
        end
      end
    end
  end
end
