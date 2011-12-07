require 'spec_helper'

describe 'API v1' do
  include Rack::Test::Methods

  def app
    KuduV1
  end

  let(:identity) { 1337 }

  let(:external_uid) {'post:$l0ngAndFiNeUId4U'}
  let(:an_item) { Item.create!(:external_uid => external_uid) }
  let(:an_ack) { Ack.create!(:item => an_item, :identity => identity, :score => 1) }

  let(:another_external_uid) {'post:$l0ngAndFiNeUId4Utoo'}
  let(:another_item) { Item.create!(:external_uid => another_external_uid) }
  let(:another_ack) { Ack.create!(:item => another_item, :identity => identity, :score => 1) }

  let(:unwanted_item) { Item.create!(:external_uid => "post:$unwanted_ack") }
  let(:unwanted_ack) { Ack.create!(:item => unwanted_item, :identity => identity, :score => 1) }

  context "with an identity" do
    let(:a_session) { {:session => "1234"} }

    before :each do
      Pebblebed::Connector.any_instance.stub(:checkpoint).and_return(DeepStruct.wrap(:me => {:id => identity, :god => false, :realm => 'safariman'}))
    end

    describe 'GET /acks/:uid' do
      it 'returns an ack for an uid given by current identity' do
        an_ack
        get "/acks/#{an_item.external_uid}", a_session
        last_response.status.should eq 200
        ack_response = JSON.parse(last_response.body)["ack"]
        ack_response['id'].should eq an_ack.id
      end

      it 'updates an existing item and recalculates it' do
        an_ack
        put "/acks/#{external_uid}", a_session.merge(:ack => {:score => 0})
        last_response.status.should eq 200
        ack_response = JSON.parse(last_response.body)["ack"]
        Ack.find_by_id(ack_response['id']).score.should eq(0)
        item = Item.find_by_external_uid(external_uid)
        item.total_count.should eq(1)
        item.positive_score.should eq(0)
      end
    end

    describe 'POST /acks/:uid' do
      it 'creates an ack and a item' do
        post "/acks/#{external_uid}", a_session.merge(:ack => {:score => "+1"})
        last_response.status.should eq 201
        ack_response = JSON.parse(last_response.body)["ack"]
        Ack.find_by_id(ack_response['id']).score.should eq(1)
        Item.find_by_external_uid(external_uid).total_count.should eq(1)
      end

      it 'updates an existing item and recalculates it' do
        an_ack
        put "/acks/#{external_uid}", a_session.merge(:ack => {:score => 0})
        last_response.status.should eq 200
        ack_response = JSON.parse(last_response.body)["ack"]
        Ack.find_by_id(ack_response['id']).score.should eq(0)
        item = Item.find_by_external_uid(external_uid)
        item.total_count.should eq(1)
        item.positive_score.should eq(0)
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

    describe "GET /items/:uids" do
      it 'gets a item of acks for a single external_uid' do
        an_ack

        get "/items/#{external_uid}"
        items = JSON.parse(last_response.body)["items"]
        items.first["item"]["external_uid"].should eq(external_uid)
      end

      it 'gets items of acks for a list of external_uids' do
        an_ack
        another_ack
        unwanted_ack

        get "/items/#{external_uid},#{another_external_uid}"
        items = JSON.parse(last_response.body)["items"]
        items.size.should eq(2)
        items.first["item"]["external_uid"].should eq(external_uid)
        items.last["item"]["external_uid"].should eq(another_external_uid)
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
