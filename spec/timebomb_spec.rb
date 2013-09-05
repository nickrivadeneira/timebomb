require 'spec_helper'

describe Timebomb do
  def app
    Timebomb
  end

  describe 'index' do
    context 'when no resources exist' do
      it 'returns no bombs' do
        get '/bombs'
        expect(last_response).to be_ok
        expect(last_response.body).to eq({bombs: []}.to_json)
      end
    end
  end

  describe 'creation' do
    context 'with valid JSON' do
      it 'creates a new bomb' do
        timestamp = Time.now.to_i
        body = {
          url:            'http://example.com',
          request_params: {foo: 1, bar: 2}.to_json,
          timestamp:      timestamp
        }.to_json
        post '/bombs/new', body, {'Content-Type' => 'application/json'}

        expect(last_response).to be_ok

        body = JSON.parse(last_response.body)
        expect(body['successful']).to be_true
        expect(body['bomb']['timestamp']).to eq timestamp
      end
    end

    context 'with no JSON' do
      it 'does not create a new bomb' do
        post '/bombs/new'

        expect(last_response.status).to eq 400
      end
    end
  end
end