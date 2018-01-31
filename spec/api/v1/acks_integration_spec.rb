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

  let(:god) {
    DeepStruct.wrap(:identity => {:id => 0, :god => true, :realm => 'realm'})
  }
  let(:alice) {
    DeepStruct.wrap(:identity => {:id => id, :god => false, :realm => 'safariman'})
  }
  let(:vincent) {
    DeepStruct.wrap(:identity => {:id => id + 1, :god => false, :realm => 'safariman'})
  }

  context 'when god' do
    describe 'GET /acks/:uid/kind' do

      it 'returns an ack for an :uid of :kind given by the given identity' do
        an_ack
        options = {
          :identity => alice.identity.id,
          :session => 'asdf'
        }
        get "/acks/#{a_score.external_uid}/kudos", options
        #raise last_response.body
        ack_response = JSON.parse(last_response.body)
        last_response.status.should eq 200
        ack_response['ack']['id'].should eq an_ack.id
        ack_response['ack']['kind'].should eq 'kudos'
      end

    end
  end

  # context "bizarre inheritance of session" do

  #   xit "works" do
  #     uid = 'post:realm.some.fine.realm$321'
  #     score = Score.create!(:external_uid => uid, :kind => 'vote')

  #     ack = Ack.create!(:score => score, :identity => id, :value => 1)
  #     get "/acks/#{score.external_uid}/vote", :identity => alice.identity.id
  #     last_response.status.should eq 200

  #   end

  # end
end
