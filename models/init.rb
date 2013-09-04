require 'mongoid'
Mongoid.load!("./config/mongoid.yml")

require_relative 'bomb'
require_relative 'client'