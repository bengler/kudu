require "./spec/spec_helper"


describe 'API v1 stats' do
  include Rack::Test::Methods

  def app
    KuduV1
  end


  describe "/acks/:uid/:kind/count" do

    it "calculates the total_count for posts in a given path" do
      base_uid = "xyz:a.b.c."
      kind = 'points'
      expected_count = 0
      3.times do |i|
        score = Score.create!(:external_uid => "#{base_uid}#{i}", :kind => kind, :total_count => (10-i), :positive => i)
        expected_count += score.total_count
      end
      get "/acks/#{base_uid}*/#{kind}/count"
      scores = JSON.parse(last_response.body)
      scores["count"].should eq expected_count
    end

  end
end
