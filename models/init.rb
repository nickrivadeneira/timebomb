require 'mongoid'
Mongoid.load!("./config/mongoid.yml", :development)

require_relative 'bomb'
require_relative 'client'