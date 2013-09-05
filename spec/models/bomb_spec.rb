require 'spec_helper'

describe Bomb do
  let(:params){
    {
      url:            'http://example.com',
      request_params: {foo: 1, bar: 2}.to_json,
      timestamp:      Time.now.to_i
    }
  }

  it 'has fields' do
    expect(described_class).to have_fields :url, :request_params, :timestamp
  end

  describe 'method to send HTTP request' do
    it 'sends a POST request' do
      request = described_class.send_request params[:url], params[:request_params]

      expect(request.request.http_method).to eq Net::HTTP::Post
      expect(request.request.path.host).to eq URI.parse(params[:url]).host
      expect(request.request.options[:body]).to eq params[:request_params]
    end
  end

  context 'instance' do
    let(:resource){described_class.create(params)}

    describe 'method to send HTTP request' do
      it 'sends a POST request' do
        request = resource.send_request

        expect(request.request.http_method).to eq Net::HTTP::Post
        expect(request.request.path.host).to eq URI.parse(resource.url).host
        expect(request.request.options[:body]).to eq resource.request_params
      end
    end
  end
end