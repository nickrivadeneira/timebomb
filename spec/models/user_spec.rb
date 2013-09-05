require 'spec_helper'
require 'bcrypt'

describe User do
  let(:email){'user@example.com'}
  let(:resource){described_class.create(email: email)}

  it 'has fields' do
    expect(described_class).to have_fields :email, :password_hash, :password_salt, :token, :token_salt
  end

  it 'does not have virtualized fields' do
    expect(described_class).to_not have_fields :password
  end

  context 'when password is not present' do
    describe 'password encryption' do
      it 'does nothing' do
        expect(resource.encrypt_password).to be_nil
      end
    end
  end

  context 'when password is present' do
    let(:password){'foobar'}
    before{resource.password = password}

    describe 'password encryption' do
      it 'encrypts the password' do
        resource.encrypt_password

        expect(resource.password_hash).to eq BCrypt::Engine.hash_secret(password, resource.password_salt)
      end
    end

    describe 'virtualized password field' do
      it 'does not store passwords' do
        resource.save

        expect(described_class.find(resource.id).password).to be_nil
      end
    end

    context 'when password is encrypted' do
      before do
        resource.encrypt_password
        resource.save
      end

      describe 'authentication' do
        context 'with invalid password' do
          it 'returns no user' do
            expect(described_class.authenticate(email, 'baz')).to eq nil
          end
        end

        context 'with valid password' do
          it 'returns the user' do
            expect(described_class.authenticate(email, password)).to eq resource
          end
        end
      end
    end
  end
end