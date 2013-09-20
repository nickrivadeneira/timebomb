require 'httparty'

class Bomb
  include Mongoid::Document

  field       :url,            type: String
  field       :request_params, type: String
  field       :timestamp,      type: Integer
  belongs_to  :user

  validates :url, :timestamp, :user_id, presence: true
  validates :timestamp, numericality: {greater_than_or_equal_to: Time.now.to_i}, on: :create
  validate  :request_params_json

  def send_request
    request = self.class.send_request self.url, self.request_params
    self.destroy and request
  end

  def self.send_request url, request_params
    HTTParty.post(url, body: request_params, headers: {'Content-Type' => 'application/json'})
  end

  def self.timed timestamp
    time        = Time.at(timestamp)
    start_time  = Time.new(time.year, time.month, time.day, time.hour).to_i
    end_time    = start_time + (60 * 60 - 1)

    Bomb.between(timestamp: start_time..end_time)
  end

  def request_params_json
    JSON.parse(self.request_params) if self.request_params.present?
  rescue JSON::ParserError, TypeError
    errors.add :request_params, 'is invalid JSON'
  end
end