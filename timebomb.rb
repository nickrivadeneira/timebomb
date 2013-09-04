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
    if (bomb = Bomb.find(params[:id]))
      bomb.to_json
    else
      404
    end
  end

  # Delete
  delete '/bombs/:id' do
    if (bomb = Bomb.find(params[:id]))
      response = bomb.to_json
      bomb.destroy
      response
    else
      404
    end
  end
end
