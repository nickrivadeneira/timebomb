require 'rubygems'
require 'sinatra'
require 'json'
require_relative 'models/init'

# Index
get '/bombs' do
  @bombs = Bomb.all(:order => :created_at.desc)
  erb :bombs_index
end

# New
get '/bombs/new' do
  erb :bombs_new
end

# Create
post '/bombs/new' do
  begin
    data = JSON.parse(request.env["rack.input"].read)
    logger.info data
    bomb = Bomb.new(data)

    if bomb.save
      logger.info bomb.to_json

      {
        successful: true,
        bomb: {
          id: bomb.id,
          url: bomb.url,
          timestamp: bomb.timestamp
        }
      }.to_json
    else
      raise
    end
  rescue => ex
    logger.info ex.class
    {successful: false, error: ex.class}.to_json
  end
end

# Show
get '/bombs/:id' do
  if (bomb = Bomb.get(params[:id]))
    bomb.to_json
  else
    404
  end
end

# Delete
delete '/bombs/:id' do
  if (bomb = Bomb.get(params[:id]))
    response = bomb.to_json
    bomb.destroy
    response
  else
    404
  end
end