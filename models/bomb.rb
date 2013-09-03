require 'httparty'
require 'json'

class Bomb
  include DataMapper::Resource
  property :id,             Serial
  property :created_at,     DateTime

  property :url,            String
  property :request_params, Text
  property :timestamp,      Integer

  def send_request
    HTTParty.post(self.url, body: self.request_params, headers: {'Content-Type' => 'application/json'})
  end
end