require 'spec_helper'

describe 'API v1 acks' do
  include Rack::Test::Methods

  def app
    KuduV1
  end

  let(:id) { 1337 }

  let(:external_uid) { 'post:realm.some.fine.realm$l0ngAndFiNeUId4U' }
  let(:a_score) { Score.create!(:external_uid => external_uid, :kind => 'kudos') }
  let(:an_ack) { Ack.create!(:score => a_score, :identity => id, :value => 1) }

  let(:checkpoint) {
    # A richer mock-checkpoint that can handle different requests differently
    class Mockpoint
      def initialize(context)
        @context = context
      end
      def get(url, *args)
        case url
        when /^\/identities\/me/
          @context.identity
        when /^\/callbacks\/allowed/
          DeepStruct.wrap(@context.callback_response)
        end
      end
    end
    Mockpoint.new(self)
  }

  before :each do
    # Pebblebed::Connector.any_instance.stub(:checkpoint).and_return(stub(:get => alice))
    Pebblebed::Connector.any_instance.stub(:checkpoint).and_return checkpoint
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

  let(:god) {
    DeepStruct.wrap(:identity => {:id => 0, :god => true, :realm => 'realm'})
  }
  let(:alice) {
    DeepStruct.wrap(:identity => {:id => id, :god => false, :realm => 'safariman'},
      :profile => alice_profile)
  }
  let(:vincent) {
    DeepStruct.wrap(:identity => {:id => id + 1, :god => false, :realm => 'safariman'})
  }

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
    let(:a_session) { {:session => "1234"} }

    context 'when god' do
      let(:callback_response) { {'allowed' => false, 'reason' => 'No way!' } }
      let(:identity) { god }
      it 'allows ack to be deleted even when callbacks dictate it should be denied' do
        delete "/acks/#{an_ack.uid}", a_session
        last_response.status.should eq 204
      end
    end

    context 'when callbacks dictate action should be allowed' do
      let(:callback_response) { {'allowed' => true } }
      let(:identity) { vincent }
      it "allows deletion even for non-owner" do
        delete "/acks/#{an_ack.uid}", a_session
        last_response.status.should eq 204
      end
    end

    context 'when callbacks dictate action should be denied' do
      let(:reason_for_denial) { 'Just forget it, pal!' }
      let(:callback_response) { {'allowed' => false, 'reason' => reason_for_denial } }
      let(:identity) { alice }
      it 'denies deletion even for owner, and returns the reason' do
        delete "/acks/#{an_ack.uid}", a_session
        last_response.status.should eq 403
        last_response.body.should include reason_for_denial
      end
    end

    context 'when callbacks dictate we use our own judgement' do
      let(:callback_response) { {'allowed' => 'default' } }
      context 'when current identity owns the ack' do
        let(:identity) { alice }
        it 'allows deletion' do
          delete "/acks/#{an_ack.uid}", a_session
          last_response.status.should eq 204
        end
      end
      context 'when current identity does not own the ack' do
        let(:identity) { vincent }
        it "denies deletion" do
          delete "/acks/#{an_ack.uid}", a_session
          last_response.status.should eq 403
        end
      end
    end
  end

  context 'when god' do
    describe 'GET /acks/:uid/kind' do
      xit 'returns an ack for an :uid of :kind given by the given identity' do
        an_ack
        get "/acks/#{a_score.external_uid}/kudos", :identity => alice.identity.id
        last_response.status.should eq 200
        ack_response = JSON.parse(last_response.body)
        ack_response['ack']['id'].should eq an_ack.id
        ack_response['ack']['kind'].should eq 'kudos'
      end
    end
  end

  context "with an identity" do
    let(:a_session) { {:session => "1234"} }
    let(:identity) { alice }

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

    context "without an identity" do
      it "is not allowed" do
        get "/acks/post:a.b.c$1/kudos"
        last_response.status.should eq 403
      end
    end

    describe 'PUT /acks/:uid/:kind' do
      let(:identity) { alice }
      let(:callback_response) { {'allowed' => 'default' } }

      it 'updates an existing score and recalculates it' do
        an_ack
        put "/acks/#{external_uid}/kudos", a_session.merge(:ack => {:value => 0})
        # puts last_response.body
        last_response.status.should eq 200
        ack_response = JSON.parse(last_response.body)["ack"]
        Ack.find_by_id(ack_response['id']).value.should eq(0)
        score = Score.find_by_external_uid(external_uid)
        score.total_count.should eq(1)
        score.positive.should eq(0)
      end

      it 'asks checkpoint for permission' do
        app.any_instance.should_receive(:require_action_allowed).
          with(:update, an_ack.uid, {:default => true})
        put "/acks/#{external_uid}/kudos", a_session.merge(:ack => {:value => 0})
      end
    end

    describe 'POST /acks/:uid/:kind' do
      let(:identity) { alice }
      let(:callback_response) { {'allowed' => 'default' } }

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

      it 'asks checkpoint for permission' do
        app.any_instance.should_receive(:require_action_allowed).
          with(:update, an_ack.uid, {:default => true})
        post "/acks/#{external_uid}/kudos", a_session.merge(:ack => {:value => 1})
      end

      context 'when called by user with no profile' do
        let(:identity) { vincent }
        it "stores nothing as profile" do
          post "/acks/#{external_uid}/kudos", a_session.merge(:ack => {:value => 1})
          last_response.status.should eq 201
          ack_response = JSON.parse(last_response.body)["ack"]
          ack = Ack.find_by_id(ack_response['id'])
          ack.created_by_profile.should eq(nil)
          Score.find_by_external_uid(external_uid).total_count.should eq(1)
        end
      end
    end

    describe 'PUT /acks/:uid/:kind' do
      let(:identity) { alice }
      let(:callback_response) { {'allowed' => 'default' } }

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
      let(:identity) { alice }
      let(:callback_response) { {'allowed' => 'default' } }
      it 'deletes an ack' do
        an_ack

        delete "/acks/#{external_uid}/kudos", a_session
        last_response.status.should eq(204)

        Ack.find_by_id(an_ack.id).should be_nil
      end

      it 'asks checkpoint for permission' do
        app.any_instance.should_receive(:require_action_allowed).
          with(:delete, an_ack.uid, {:default => true})
        delete "/acks/#{external_uid}/kudos", a_session
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
