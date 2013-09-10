require './models/init'
require 'stalker'
include Stalker

job 'queue.requests' do |args|
  bombs = Bomb.timed args['timestamp']
  bombs.each do |bomb|
    enqueue 'send.request', id: bomb._id
  end
end

job 'send.request' do |args|
  Bomb.find(args['id']).send_request
end