require 'spec_helper'

describe Timebomb do
  def app
    Timebomb
  end

  let(:bomb_params){
    {
      url:            'http://example.com',
      request_params: {foo: 1, bar: 2}.to_json,
      timestamp:      Time.now.to_i
    }
  }
  let(:user){User.create}
  let(:token){user.tokens.create.token}

  describe 'authentication' do
    context 'with a valid token via querystring parameters' do
      it 'is successful' do
        get '/bombs', token: token
        expect(last_response).to be_ok
      end
    end

    context 'with a valid token via header' do
      it 'is successful' do
        get '/bombs', nil, 'HTTP_AUTHORIZATION' => 'Token ' + token
        expect(last_response).to be_ok
      end
    end

    context 'with an invalid token' do
      it 'returns a 401 status' do
        get '/bombs'
        expect(last_response.status).to eq 401

        post '/bombs/new'
        expect(last_response.status).to eq 401

        get '/bombs/foo'
        expect(last_response.status).to eq 401

        delete '/bombs/foo'
        expect(last_response.status).to eq 401
      end
    end
  end

  describe 'index' do
    context 'when no resources exist' do
      it 'returns no bombs' do
        get '/bombs', token: token

        expect(last_response).to be_ok
        expect(last_response.body).to eq({bombs: []}.to_json)
      end
    end

    context 'when 5 bombs exist' do
      before do
        3.times{user.bombs.create(bomb_params)}
        2.times{Bomb.create}
      end

      it 'returns only the user\'s 3 bombs' do
        get '/bombs', token: token

        expect(last_response).to be_ok and body = JSON.parse(last_response.body)
        expect(body['bombs'].size).to eq 3
        expect(body['bombs'].map{|b| b['_id']}.uniq.size).to eq 3
        expect(Bomb.count).to eq 5
      end
    end
  end

  describe 'creation' do
    context 'with valid JSON' do
      it 'creates a new bomb' do
        post '/bombs/new?token=' + token, bomb_params.to_json, {'Content-Type' => 'application/json'}

        expect(last_response).to be_ok and body = JSON.parse(last_response.body)
        expect(body['bomb']['timestamp']).to eq bomb_params[:timestamp]
        expect(body['bomb']['user_id']).to eq user._id.to_s
      end
    end

    context 'with no JSON' do
      it 'does not create a new bomb' do
        post '/bombs/new', token: token

        expect(last_response.status).to eq 400
      end
    end
  end

  describe 'show' do
    context 'authorized existing bomb' do
      it 'returns the user\'s bomb' do
        bomb = user.bombs.create(bomb_params)
        get '/bombs/' + bomb._id.to_s, token: token

        expect(last_response).to be_ok and body = JSON.parse(last_response.body)
        expect(body['bomb']['_id']).to eq(bomb._id.to_s)
        expect(body['bomb']['url']).to eq(bomb.url)
        expect(body['bomb']['request_params']).to eq(bomb.request_params)
        expect(body['bomb']['timestamp']).to eq(bomb.timestamp)
      end
    end

    context 'unauthorized existing bomb' do
      it 'returns 404' do
        bomb = Bomb.create
        get '/bombs/' + bomb._id.to_s, token: token

        expect(last_response.status).to be 404
      end
    end

    context 'non-existing bomb' do
      it 'returns 404' do
        get '/bombs/foobar', token: token

        expect(last_response.status).to eq 404
      end
    end
  end

  describe 'delete' do
    context 'authorized existing bomb' do
      it 'deletes and returns the bomb' do
        bomb = user.bombs.create bomb_params
        delete '/bombs/' + bomb._id.to_s, token: token

        expect(last_response).to be_ok and body = JSON.parse(last_response.body)
        expect(body['bomb']['_id']).to eq bomb._id.to_s
      end
    end

    context 'unauthorized existing bomb' do
      it 'returns 404' do
        bomb = Bomb.create
        delete '/bombs/' + bomb._id.to_s, token: token

        expect(last_response.status).to eq 404
      end
    end

    context 'non-existing bomb' do
      it 'returns 404' do
        delete '/bombs/foo', token: token

        expect(last_response.status).to eq 404
      end
    end
  end
end