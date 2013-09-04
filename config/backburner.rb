require 'backburner'
Backburner.configure do |config|
  config.beanstalk_url    = ["beanstalk://127.0.0.1"]
  config.tube_namespace   = "timebomb"
  config.on_error         = lambda { |e| puts e }
  config.max_job_retries  = 3 # default 0 retries
  config.logger           = Logger.new(STDOUT)
  config.primary_queue    = "timbomb-jobs"
end