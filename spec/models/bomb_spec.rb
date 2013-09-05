require 'spec_helper'

describe Bomb do
  let(:timestamp){Time.now.to_i}
  let(:params){
    {
      url:            'http://example.com',
      request_params: {foo: 1, bar: 2}.to_json,
      timestamp:      timestamp
    }
  }

  it 'has fields' do
    expect(described_class).to have_fields :url, :request_params, :timestamp
  end

  describe 'timed scope' do
    context 'with 2 out-of-scope records and 1 in-scope record' do
      before do
        interval_minutes = 60
        offsets = [-60 * interval_minutes * 2, 0, 60 * interval_minutes * 2]
        offsets.each do |offset|
          described_class.create(timestamp: timestamp + offset)
        end
      end

      it 'returns the in-scope record' do
        expect(described_class.count).to eq 3
        expect(described_class.timed(timestamp).count).to eq 1
      end
    end
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