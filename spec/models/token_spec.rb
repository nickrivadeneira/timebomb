require 'spec_helper'

describe Token do
  let(:user){User.create}
  let(:resource){user.tokens.create}

  it 'has fields' do
    expect(described_class).to have_fields :token
  end

  it 'is embedded in User' do
    expect(described_class).to be_embedded_in :user
  end

  describe 'token creation' do
    it 'sets token to a random url safe string' do
      resource.generate_token
      expect(resource.token.size).to be 22
    end
  end

  describe 'token callback' do
    it 'triggers token creation' do
      new_token = user.tokens.create
      expect(new_token.token.size).to be 22
    end
  end
end