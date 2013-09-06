class Timebomb < Sinatra::Base
  # Authenticate
  before do
    token = params[:token] || (env['HTTP_AUTHORIZATION'] || '')[/[\w|-]{22}/]
    halt 401 if token.blank? || (@user = User.authenticate_token(token)).nil?
  end

  # Index
  get '/bombs' do
    bombs = @user.bombs
    {bombs: bombs}.to_json
  end

  # Create
  post '/bombs/new' do
    begin
      data = JSON.parse(request.env['rack.input'].read)
      bomb = @user.bombs.new(url: data['url'], request_params: data['request_params'], timestamp: data['timestamp'])

      if bomb.save
        {
          bomb: {
            _id: bomb._id,
            url: bomb.url,
            request_params: bomb.request_params,
            timestamp: bomb.timestamp,
            user_id: bomb.user._id
          }
        }.to_json
      else
        raise
      end
    rescue JSON::ParserError
      400
    rescue
      500
    end
  end

  # Show
  get '/bombs/:id' do
    begin
      @user.bombs.find(params[:id]).to_json
    rescue Mongoid::Errors::DocumentNotFound
      404
    end
  end

  # Delete
  delete '/bombs/:id' do
    begin
      bomb = @user.bombs.find(params[:id])
      response = bomb.to_json
      bomb.destroy and response or 500
    rescue Mongoid::Errors::DocumentNotFound
      404
    end
  end
end
