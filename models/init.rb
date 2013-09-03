require 'data_mapper'
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

require_relative 'bomb'
require_relative 'client'

DataMapper.finalize
DataMapper.auto_upgrade!
