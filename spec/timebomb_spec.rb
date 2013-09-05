ENV['RACK_ENV'] = 'test'

require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

describe 'Timebomb' do
  include Rack::Test::Methods

  def app
    Timebomb
  end

  it "should return bombs" do
    get '/bombs'
    last_response.should be_ok
    last_response.body.should == {bombs: []}.to_json
  end
end