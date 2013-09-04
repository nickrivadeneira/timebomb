require 'httparty'

class Bomb
  include Mongoid::Document
  field :url,            type: String
  field :request_params, type: String
  field :timestamp,      type: Integer

  def send_request
    self.class.send_request self.url, self.request_params
  end

  def self.send_request url, request_params
    HTTParty.post(url, body: request_params, headers: {'Content-Type' => 'application/json'})
  end
end