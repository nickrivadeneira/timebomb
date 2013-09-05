require 'spec_helper'

describe Bomb do
  it 'has fields' do
    expect(described_class).to have_fields :url, :request_params, :timestamp
  end

  context 'instance' do
    let(:bomb_params){
      {
        url:            'http://example.com',
        request_params: {foo: 1, bar: 2}.to_json,
        timestamp:      Time.now.to_i
      }
    }
    let(:bomb){Bomb.create(bomb_params)}

    describe 'method to send HTTP request' do
      it 'sends a POST request' do
        request = bomb.send_request

        expect(request.request.http_method).to eq Net::HTTP::Post
        expect(request.request.path.host).to eq URI.parse(bomb.url).host
        expect(request.request.options[:body]).to eq bomb.request_params
      end
    end
  end
end