require 'bcrypt'

class User
  include Mongoid::Document

  field       :email,         type: String
  field       :password_hash, type: String
  field       :password_salt, type: String
  embeds_many :tokens

  attr_accessor :password

  def self.authenticate email, password
    user = where(email: email).first
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret password, password_salt
    end
  end
end