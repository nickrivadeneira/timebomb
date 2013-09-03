require_relative 'models/init'

task :send_requests do
  now_time    = Time.now
  start_time  = Time.new(now_time.year, now_time.month, now_time.day, now_time.hour).to_i
  end_time    = start_time + (60 * 60 - 1)
  bombs       = Bomb.all(timestamp: (start_time..end_time))

  bombs.each do |bomb|
    bomb.send_request
  end
end