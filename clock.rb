require 'stalker'
include Clockwork

handler{|job| Stalker.enqueue job, timestamp: Time.now.to_i}
every 60.minutes, 'queue.requests'