require 'mongoid'
Mongoid.load!("./config/mongoid.yml", ENV["RACK_ENV"] || :development)
Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file }