require 'uri'

class Client
  class ClientError < StandardError; end
  class AuthenticationError < ClientError; end
  LOCAL_URL = 'http://localhost:3000/api'

  attr_reader :email, :password, :url

  def initialize(email, password, url = LOCAL_URL)
    @email, @password, @url = email, password, url
  end

  def token
    @token ||= login!
  end

  def login!
    response = Faraday.post(session_url, {user_email: email, password: password}, headers)
    raise AuthenticationError if response.status == 401
    raise ClientError unless response.success?
    JSON.parse(response.body)['session']['token']
  end

  def user(email)
    response = Faraday.get(user_url(email), headers)
    return nil if response.status == 404
    raise AuthenticationError if response.status == 401
    raise ClientError unless response.success?
    JSON.parse(response.body)['user']
  end

  def logged_in?
    @token.present?
  end

  def session_url
    "#{url}/sessions"
  end

  def user_url(email)
    "#{url}/users/#{URI.escape(email)}"
  end

  def headers
    headers = {}
    headers['Accept'] = 'application/json'
    headers['X-AuthenticationToken'] = token if logged_in?
    headers
  end
end