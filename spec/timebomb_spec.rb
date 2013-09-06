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

  context 'while authenticated' do
    let(:user){User.create}
    let(:token){user.tokens.create.token}

    describe 'index' do
      context 'when no resources exist' do
        it 'returns no bombs' do
          get '/bombs?token=' + token

          expect(last_response).to be_ok
          expect(last_response.body).to eq({bombs: []}.to_json)
        end
      end

      context 'when 5 bombs exist' do
        before do
          5.times do
            Bomb.create(bomb_params)
          end
        end

        it 'returns all 5 bombs' do
          get '/bombs?token=' + token

          expect(last_response).to be_ok and body = JSON.parse(last_response.body)
          expect(body['bombs'].size).to eq 5
          expect(body['bombs'].map{|b| b['_id']}.uniq.size).to eq 5
        end
      end
    end

    describe 'creation' do
      context 'with valid JSON' do
        it 'creates a new bomb' do
          post '/bombs/new?token=' + token, bomb_params.to_json, {'Content-Type' => 'application/json'}

          expect(last_response).to be_ok and body = JSON.parse(last_response.body)
          expect(body['successful']).to be_true
          expect(body['bomb']['timestamp']).to eq bomb_params[:timestamp]
        end
      end

      context 'with no JSON' do
        it 'does not create a new bomb' do
          post '/bombs/new?token=' + token

          expect(last_response.status).to eq 400
        end
      end
    end

    describe 'show' do
      context 'existing bomb' do
        let(:bomb){Bomb.create(bomb_params)}

        it 'returns the bomb' do
          get '/bombs/' + bomb._id.to_s + '?token=' + token

          expect(last_response).to be_ok and body = JSON.parse(last_response.body)
          expect(body['_id']).to eq(bomb._id.to_s)
          expect(body['url']).to eq(bomb.url)
          expect(body['request_params']).to eq(bomb.request_params)
          expect(body['timestamp']).to eq(bomb.timestamp)
        end
      end

      context 'non-existing bomb' do
        it 'returns 404' do
          get '/bombs/foobar?token=' + token

          expect(last_response.status).to eq 404
        end
      end
    end

    describe 'delete' do
      context 'existing bomb' do
        let(:bomb){Bomb.create(bomb_params)}

        it 'deletes and returns the bomb' do
          delete '/bombs/' + bomb._id.to_s + '?token=' + token

          expect(last_response).to be_ok and body = JSON.parse(last_response.body)
          expect(body['_id']).to eq bomb._id.to_s
        end
      end

      context 'non-existing bomb' do
        it 'returns 404' do
          delete '/bombs/foo?token=' + token

          expect(last_response.status).to eq 404
        end
      end
    end
  end

  context 'while not authenticated' do
    describe 'index' do
      it 'returns 401' do
        get '/bombs'

        expect(last_response.status).to eq 401
      end
    end

    describe 'creation' do
      it 'returns 401' do
        post '/bombs/new'
        expect(last_response.status).to eq 401
      end
    end

    describe 'show' do
      it 'returns 401' do
        get '/bombs/foo'
        expect(last_response.status).to eq 401
      end
    end

    describe 'delete' do
      it 'returns 401' do
        delete '/bombs/foo'
        expect(last_response.status).to eq 401
      end
    end
  end
end