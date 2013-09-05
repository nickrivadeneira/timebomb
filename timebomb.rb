class Timebomb < Sinatra::Base
  # Index
  get '/bombs' do
    bombs = Bomb.desc(:created_at).all
    {bombs: bombs}.to_json
  end

  # Create
  post '/bombs/new' do
    begin
      data = JSON.parse(request.env["rack.input"].read)
      bomb = Bomb.new(url: data["url"], request_params: data["request_params"], timestamp: data["timestamp"])

      if bomb.save
        logger.info bomb.to_json

        {
          successful: true,
          bomb: {
            _id: bomb._id,
            url: bomb.url,
            request_params: bomb.request_params,
            timestamp: bomb.timestamp
          }
        }.to_json
      else
        raise
      end
    rescue JSON::ParserError
      400
    rescue => ex
      puts ex
      500
    end
  end

  # Show
  get '/bombs/:id' do
    begin
      Bomb.find(params[:id]).to_json
    rescue Mongoid::Errors::DocumentNotFound
      404
    end
  end

  # Delete
  delete '/bombs/:id' do
    begin
      bomb = Bomb.find(params[:id])
      response = bomb.to_json
      bomb.destroy and response or 500
    rescue Mongoid::Errors::DocumentNotFound
      404
    end
  end
end
