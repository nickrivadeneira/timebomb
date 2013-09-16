class Timebomb < Sinatra::Base
  enable :sessions
  set :haml, format: :html5, layout: :layout

  ['/bombs*', '/token*'].each do |path|
    before path do
      cors_headers
      @request_body = env['rack.input'].read

      # Authenticate
      token = session[:token] ||
              params[:token] ||
              JSON.parse(@request_body)['token'] rescue nil ||
              env['HTTP_AUTHORIZATION'][/[\w|-]{22}/] rescue nil
      halt 401, haml(:sessions_new) if token.blank? || (@user = User.authenticate_token(token)).nil?
    end
  end

  # Index
  get '/bombs' do
    {bombs: @user.bombs}.to_json
  end

  # Create
  post '/bombs' do
    data = JSON.parse(@request_body) rescue Hash.new()
    bomb_params = Hash.new()

    bomb_params[:url]             = data['url']             || params[:url]
    bomb_params[:request_params]  = data['request_params']  || params[:request_params].to_json
    bomb_params[:timestamp]       = data['timestamp']       || params[:timestamp]

    halt 400 if bomb_params[:url].blank? || bomb_params[:timestamp].blank?

    bomb = @user.bombs.create(bomb_params) and {bomb: bomb}.to_json or raise
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
      bomb.destroy and response or raise
    rescue Mongoid::Errors::DocumentNotFound
      404
    end
  end

  get '/tokens' do
    {tokens: @user.tokens}.to_json
  end

  # User registration
  get '/signup' do
    haml :users_new
  end

  post '/users' do
    if params[:email].present? && params[:password].present?
      if (user = User.create email: params[:email], password: params[:password])
        session[:token] = user.tokens.first.token
        redirect '/bombs'
      end
    end
  end

  # Sessions
  get '/signin' do
    if session[:token].present?
      redirect '/bombs'
    else
      haml :sessions_new
    end
  end

  post '/signin' do
    if params[:email].present? && params[:password].present?
      user = User.authenticate params[:email], params[:password]
      if user
        session[:token] = user.tokens.first.token
        redirect '/bombs'
      else
        redirect '/signin'
      end
    end
  end

  get '/signout' do
    session[:token] = nil
    redirect '/signin'
  end

  private
    # Approve pre-flight and return if CORS. Do not check authorization.
    def cors_headers
      headers 'Access-Control-Allow-Origin' => '*',
              'Access-Control-Allow-Headers' => 'Content-Type, Authorization'

      halt 200 if request.request_method == 'OPTIONS'
    end
end
