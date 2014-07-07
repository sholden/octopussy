module CryptoSerializer
  def self.load(encrypted)
    key = Rails.configuration.secret_key_base
    encryptor = ActiveSupport::MessageEncryptor.new(key)
    encryptor.decrypt_and_verify(encrypted)
  end

  def self.dump(decrypted)
    key = Rails.configuration.secret_key_base
    encryptor = ActiveSupport::MessageEncryptor.new(key)
    encryptor.encrypt_and_sign(decrypted)
  end
end