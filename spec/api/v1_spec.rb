require 'spec_helper'

describe 'API v1' do
  include Rack::Test::Methods

  def app
    KuduV1
  end

  it "is true" do
    1.should eq(1)
  end
end
