require 'securerandom'

class Token
  include Mongoid::Document
  before_save :generate_token

  field       :token, type: String
  embedded_in :user

  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end
end