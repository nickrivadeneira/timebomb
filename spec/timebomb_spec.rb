ENV['RACK_ENV'] = 'test'

require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

describe 'Timebomb' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should return bombs" do
    get '/bombs'
    puts last_response.inspect
    last_response.should be_ok
    last_response.body.should == '{}'
  end
end