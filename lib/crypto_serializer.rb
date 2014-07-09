module CryptoSerializer
  def self.load(encrypted)
    key = Octopussy::Application.config.secret_token
    encryptor = ActiveSupport::MessageEncryptor.new(key)
    encryptor.decrypt_and_verify(encrypted)
  end

  def self.dump(decrypted)
    key = Octopussy::Application.config.secret_token
    encryptor = ActiveSupport::MessageEncryptor.new(key)
    encryptor.encrypt_and_sign(decrypted)
  end
end