require 'spec_helper'
require 'bcrypt'

describe User do
  it 'has fields' do
    expect(described_class).to have_fields :email, :password_hash, :password_salt, :token, :token_salt
  end

  describe 'password encryption' do
    let(:resource){described_class.create}

    context 'when password is not present' do
      it 'does nothing' do
        expect(resource.encrypt_password).to be_nil
      end
    end

    context 'when password is present' do
      let(:password){"foobar"}

      it 'encrypts the password' do
        resource.password = password
        resource.encrypt_password

        expect(resource.password_hash).to eq BCrypt::Engine.hash_secret(password, resource.password_salt)
      end
    end
  end
end