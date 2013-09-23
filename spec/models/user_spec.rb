require 'spec_helper'
require 'bcrypt'
require 'base64'

describe User do
  let(:email){'user@example.com'}
  let(:password){'foobar'}
  let(:user_params){
    {
      email: email,
      password: password
    }
  }
  let(:resource){described_class.create(user_params)}

  it 'has fields' do
    expect(described_class).to have_fields :email, :password_hash, :password_salt
  end

  it 'embeds many tokens' do
    expect(described_class).to embed_many :tokens
  end

  it 'has many bombs' do
    expect(described_class).to have_many :bombs
  end

  it 'does not have virtualized fields' do
    expect(described_class).to_not have_fields :password
  end

  # Disabled due to password encryption callback.
  # context 'when password is not present' do
  #   describe 'password encryption' do
  #     it 'does nothing' do
  #       expect(resource.encrypt_password).to be_nil
  #     end
  #   end
  # end

  context 'when password is present' do
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

  describe 'basic authentication' do
    before{resource}
    context 'with valid credentials' do
      it 'returns the correct user' do
        encoded = Base64.encode64(email + ':' + password)
        expect(described_class.authenticate_base64 encoded).to eq resource
      end
    end

    context 'with invalid credentials' do
      it 'does not return the user' do
        encoded = Base64.encode64(email + ':' + password + 'baz')
        expect(described_class.authenticate_base64 encoded).to be_nil
      end
    end
  end

  describe 'token authentication' do
    context 'when token is not present' do
      it 'returns nothing' do
        expect(described_class.authenticate_token 'foobar').to be_nil
      end
    end

    context 'when token is present' do
      it 'returns parent user' do
        token = resource.tokens.create.token
        expect(described_class.authenticate_token token).to eq resource
      end
    end
  end

  describe 'validation' do
    it 'validates uniqueness for email' do
      expect(described_class).to validate_uniqueness_of :email
    end

    it 'validates presence for email' do
      expect(described_class).to validate_presence_of :email
    end

    it 'prevents duplicate email addresses' do
      resource1 = described_class.create(email: email)
      resource2 = resource1.dup

      expect(resource1).to be_valid
      expect(resource2).to_not be_valid
    end
  end

  describe 'callbacks' do
    before{@new_resource = described_class.new(email: email, password: password)}

    context 'before create' do
      it 'encrypts the password' do
        expect(@new_resource.password_hash).to be_nil
        @new_resource.save
        expect(@new_resource.password_hash).to_not be_nil
      end
    end

    context 'after create' do
      it 'creates a token' do
        expect(@new_resource.tokens).to be_empty
        @new_resource.save
        expect(@new_resource.tokens).to_not be_empty
      end
    end
  end
end