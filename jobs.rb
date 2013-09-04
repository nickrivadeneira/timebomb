require './models/init'
require 'stalker'
include Stalker

job 'queue.requests' do |args|
  bombs = Bomb.timed args['timestamp']
  bombs.each do |bomb|
    enqueue 'send.request', url: bomb.url, request_params: bomb.request_params
  end
end

job 'send.request' do |args|
  Bomb.send_request args['url'], args['request_params']
end