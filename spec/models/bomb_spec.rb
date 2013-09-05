require 'spec_helper'

describe Bomb do
  it 'has fields' do
    expect(described_class).to have_fields :url, :request_params, :timestamp
  end
end