require 'spec_helper'

describe User do
  it 'has fields' do
    expect(described_class).to have_fields :email, :password, :password_salt, :token, :token_salt
  end
end