require 'mongoid'
Mongoid.load!("./config/mongoid.yml", ENV["RACK_ENV"] || :development)

require_relative 'bomb'
require_relative 'client'