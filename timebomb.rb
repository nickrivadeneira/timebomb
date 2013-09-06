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
      data = JSON.parse(request.body.read) rescue Hash.new()
      bomb_params = Hash.new()

      bomb_params[:url]             = data['url']             || params[:url]
      bomb_params[:request_params]  = data['request_params']  || params[:request_params]
      bomb_params[:timestamp]       = data['timestamp']       || params[:timestamp]

      halt 400 if bomb_params[:url].blank? || bomb_params[:timestamp].blank?

      {bomb: @user.bombs.create(bomb_params)}.to_json
    rescue
      500
    end
  end

  # Show
  get '/bombs/:id' do
    begin
      {bomb: @user.bombs.find(params[:id])}.to_json
    rescue Mongoid::Errors::DocumentNotFound
      404
    end
  end

  # Delete
  delete '/bombs/:id' do
    begin
      bomb = @user.bombs.find(params[:id])
      response = {bomb: bomb}.to_json
      bomb.destroy and response or 500
    rescue Mongoid::Errors::DocumentNotFound
      404
    end
  end
end
