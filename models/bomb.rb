require 'httparty'
require 'origin'
require 'backburner'

class Bomb
  include Mongoid::Document
  include Origin::Queryable
  include Backburner::Performable
  queue "bomb-jobs"

  field :url,            type: String
  field :request_params, type: String
  field :timestamp,      type: Integer

  def send_request
    self.class.send_request self.url, self.request_params
  end

  def self.send_request url, request_params
    HTTParty.post(url, body: request_params, headers: {'Content-Type' => 'application/json'})
  end

  def self.timed timestamp
    now_time    = Time.now
    start_time  = Time.new(now_time.year, now_time.month, now_time.day, now_time.hour).to_i
    end_time    = start_time + (60 * 60 - 1)

    Bomb.between(timestamp: start_time..end_time)
  end
end