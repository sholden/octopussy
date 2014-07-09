class AuthenticationToken
  attr_reader :token_hash

  def self.parse(encrypted_token)
    new(JSON.parse(CryptoSerializer.load(encrypted_token)))
  rescue
    nil
  end

  def self.build(user)
    new({'user_email' => user.email, 'current_shard' => user.current_shard})
  end

  def initialize(token_hash)
    @token_hash = token_hash
  end

  def user_email
    @token_hash['user_email']
  end

  def current_shard
    @token_hash['current_shard']
  end

  def user
    User.find_by_email(user_email)
  end

  def to_s
    CryptoSerializer.dump(JSON.dump(token_hash))
  end
end