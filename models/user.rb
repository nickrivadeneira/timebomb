require 'bcrypt'
require 'base64'

class User
  include Mongoid::Document
  before_create :encrypt_password
  after_create  {self.tokens.create}

  field       :email,         type: String
  field       :password_hash, type: String
  field       :password_salt, type: String
  has_many    :bombs
  embeds_many :tokens

  attr_accessor :password

  validates :email, uniqueness: true
  validates :email, presence: true

  def self.authenticate email, password
    user = where(email: email).first
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def self.authenticate_base64 enc
    plain = Base64.decode64 enc
    email, *password = plain.split(/:/)
    authenticate email, password.join
  end

  def self.authenticate_token token
    where(:'tokens.token' => token).first if token.is_a? String
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret password, password_salt
    end
  end
end