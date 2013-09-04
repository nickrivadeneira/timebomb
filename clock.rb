require 'backburner'
require './models/init'
require './config/backburner'
include Clockwork

class RequestJob
  def self.perform timestamp
    bombs = Bomb.timed timestamp
    bombs.each do |id|
      bomb.async.send_request
    end
  end
end

every(1.hour, 'send.request'){Backburner.enqueue RequestJob Time.now.to_i}