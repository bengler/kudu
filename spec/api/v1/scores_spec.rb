require "./spec/spec_helper"
require "active_support/time"
require 'spec/utils/mockpoint'

describe 'API v1 scores' do
  include Rack::Test::Methods

  def app
    KuduV1
  end

  let(:checkpoint) {
    Mockpoint.new(self)
  }

  before :each do
    Pebblebed::Connector.any_instance.stub(:checkpoint).and_return checkpoint
  end

  let(:identity) { DeepStruct.wrap(:identity => {:id => 1337, :god => false, :realm => 'safariman'}) }
  let(:callback_response) { {'allowed' => 'default' } }

  describe "GET /scores/:uid(s)/:kind" do

    it 'gets a score of acks for a single external_uid' do
      uid = 'post:realm.some.path$l0ngAndFiNeUId4Utoo'
      Score.create!(:external_uid => uid, :kind => 'kudos')
      get "/scores/#{uid}/kudos"
      score = JSON.parse(last_response.body)["score"]
      score["external_uid"].should eq(uid)
    end

    it 'respects species for a collection query' do
      Score.create!(:external_uid => 'post.comment:some.path$1', :kind => 'kudos')
      Score.create!(:external_uid => 'post.topic:some.path$1', :kind => 'kudos')
      get "/scores/post.comment:some.*/kudos"
      scores = JSON.parse(last_response.body)["scores"]
      scores.size.should eq(1)
    end

    it 'gets scores for a collection of uids using wildcard path' do
      uids = %w(post:realm.some.path$1 post:realm.some.otherpath$2 post:otherrealm.some.path$3)
      Score.create!(:external_uid => uids[0], :kind => 'kudos')
      Score.create!(:external_uid => uids[1], :kind => 'stars') # should not include wrong kinds
      Score.create!(:external_uid => uids[2], :kind => 'kudos') # should not include wrong paths

      get "/scores/post:realm.some.*/kudos"
      scores = JSON.parse(last_response.body)["scores"]
      scores.size.should eq(1)
      scores.map {|entry| entry["score"]["external_uid"] }.should eq(["post:realm.some.path$1"])
    end

    it 'ranks the scores when the :rank parameter is provided'

    it 'gets scores of acks for a list of external_uids, in the order they are asked for' do

      uids = %w(post:realm.some.path$1 post:realm.some.path$2 post:realm.some.path$3)
      Score.create!(:external_uid => uids[0], :kind => 'kudos')
      Score.create!(:external_uid => uids[1], :kind => 'kudos')
      Score.create!(:external_uid => uids[2], :kind => 'kudos')

      get "/scores/#{uids[1]},#{uids[0]}/kudos"

      scores = JSON.parse(last_response.body)["scores"]
      scores.size.should eq(2)
      scores.first["score"]["external_uid"].should eq(uids[1])
      scores.last["score"]["external_uid"].should eq(uids[0])
    end

    it 'gets scores of acks updated after a date' do

      uids = ['post:realm.some.path$1', 'post:realm.some.path$2']
      Score.create!(external_uid: uids[0], kind: 'kudos', created_at: '2014-01-01', updated_at: '2014-01-01')
      Score.create!(external_uid: uids[1], kind: 'kudos', created_at: Time.now)

      url = "/scores/#{uids[1]},#{uids[0]}/kudos"
      get url, {updated_after: '2015-01-01'}

      scores = JSON.parse(last_response.body)["scores"].compact
      scores.size.should eq(1)
      scores.first["score"]["external_uid"].should eq(uids[1])
    end

  end

  describe "POST /scores/:uid/:kind/touch" do
    let (:an_uid) { 'post:realm.some.path$1' }
    it 'creates a score waiting for acks to happen' do
      post "/scores/#{an_uid}/kudos/touch", :session => 1234
      last_response.status.should eq 201
      score =  JSON.parse(last_response.body)['score']
      score["external_uid"].should eq(an_uid)
    end

    it "doesn't tamper with an already existing score" do
      a_week_ago = Time.now - 7.days
      Score.create!(:external_uid => an_uid, :kind => 'votes', :created_at => a_week_ago)
      post "/scores/#{an_uid}/votes/touch", :session => 1234
      last_response.status.should eq 200
      score = JSON.parse(last_response.body)['score']
      Time.parse(score['created_at']).to_i.should eq(a_week_ago.to_i)
      score["external_uid"].should eq(an_uid)
    end
  end

  describe "GET /scores/:uid/:kind/acks" do
    let (:an_uid) { 'post:earth.some.path$1' }
    let(:access_to_response) { {:access => {:granted => true }} }

    it 'returns a paginated list of acks for a given uid' do
      score = Score.create!(:external_uid => an_uid, :kind => 'kudos')
      Ack.create!(:score => score, :identity => 1, :value => 1)
      Ack.create!(:score => score, :identity => 2, :value => 1)

      get "/scores/#{an_uid}/kudos/acks", :session => 1234

      last_response.status.should eq 200
      JSON.parse(last_response.body)['acks'].length.should eq(2)
    end

    context "Session belongs to a regular user" do
      let(:access_to_response) { {:access => {:granted => false }} }

      it "doesn't expose the ip of the ack" do
        score = Score.create!(:external_uid => an_uid, :kind => 'kudos')
        Ack.create!(:score => score, :identity => 1, :value => 1)
        Ack.create!(:score => score, :identity => 2, :value => 1)

        get "/scores/#{an_uid}/kudos/acks", :session => 1234

        JSON.parse(last_response.body)['acks'].collect {|a| a['ack']['ip']}.uniq.should eq(['[protected]'])
      end
    end

    context "User has a god role in requested realm" do
      let(:identity) { DeepStruct.wrap(:identity => {:id => 1337, :god => true, :realm => 'earth'}) }
      it "exposes the ip of the ack" do
        score = Score.create!(:external_uid => an_uid, :kind => 'kudos')
        Ack.create!(:score => score, :identity => 1, :value => 1, :ip => '127.0.0.1')
        Ack.create!(:score => score, :identity => 2, :value => 1, :ip => '10.0.0.1')

        get "/scores/#{an_uid}/kudos/acks", :session => 1234

        JSON.parse(last_response.body)['acks'].collect {|a| a['ack']['ip']}.should eq(['127.0.0.1', '10.0.0.1'])
      end
    end

    context "User has a god role. but not in requested realm" do
      let(:identity) { DeepStruct.wrap(:identity => {:id => 1337, :god => true, :realm => 'moon'})}
      let(:access_to_response) { {:access => {:granted => false }} }
      it "exposes the ip of the ack for gods" do
        score = Score.create!(:external_uid => an_uid, :kind => 'kudos')
        Ack.create!(:score => score, :identity => 1, :value => 1, :ip => '127.0.0.1')
        Ack.create!(:score => score, :identity => 2, :value => 1, :ip => '10.0.0.1')

        get "/scores/#{an_uid}/kudos/acks", :session => 1234

        JSON.parse(last_response.body)['acks'].collect {|a| a['ack']['ip']}.uniq.should eq(['[protected]'])
      end
    end
  end

  describe "DELETE /scores/:uid/:kind/acks/:id" do
    let (:an_uid) { 'post:earth.some.path$1' }

    context "Regular user" do
      let(:identity) { DeepStruct.wrap(:identity => {:id => 1337, :god => false, :realm => 'moon'})}

      it 'denies regular users access to delete an ack' do
        score = Score.create!(:external_uid => an_uid, :kind => 'kudos')
        ack = Ack.create!(:score => score, :identity => 1, :value => 1)

        delete "/scores/#{an_uid}/kudos/acks/#{ack.id}", :session => 1234

        last_response.status.should eq 403
      end
    end

    context "User is god of the realm" do
      let(:identity) { DeepStruct.wrap(:identity => {:id => 1337, :god => true, :realm => 'earth'})}
      it 'allows gods of the domain to delete an ack' do

        score = Score.create!(:external_uid => an_uid, :kind => 'kudos')
        ack = Ack.create!(:score => score, :identity => 1, :value => 1)

        delete "/scores/#{an_uid}/kudos/acks/#{ack.id}", :session => 1234

        last_response.status.should eq 200
      end
    end
  end

  describe "GET /scores/:path/:kind/rank/:by" do

    it "fetches the top 10 by default" do
      base_uid = "xyz:a.b.c."
      3.times do |i|
        Score.create!(:external_uid => "#{base_uid}#{i}", :kind => 'points', :total_count => (10-i), :positive => i)
      end
      get "/scores/#{base_uid}*/points/rank/positive", :direction => 'asc', :limit => 2
      scores = JSON.parse(last_response.body)["scores"]
      scores.size.should eq(2)
      scores.map {|entry| entry["score"]["positive"] }.should eq([0, 1])
    end

  end
end
