class Twitter < ActiveRecord::Base
  include ApplicationHelper

  @@base_url = "https://api.twitter.com"
  @@consumer_key = OAuth::Consumer.new(Rails.application.secrets.twitter_api_key,Rails.application.secrets.twitter_api_secret)

  def self.execute(options = {})
    api_call = URI("#{@@base_url}/1.1/#{options[:request_type]}") # The verify credentials endpoint returns a 200 status if the request is signed correctly.
    user = options[:user]
    auth_token = user.auth_token
    auth_secret = user.auth_secret
    Twitter.get_response(auth_token, auth_secret, api_call)
  end

  def self.update_records
    History.create(user_id: 1, followers_count: 22)
  end

  # Methods for setting up the request:
  ######################################
  def self.get_response(auth_token, auth_secret, api_call)
    access_token = create_access_token(auth_token, auth_secret)
    http = set_http_request(api_call)
    authorized_request = authorize_request(http, access_token, api_call)
    response = http.request(authorized_request) # Issue the request and store the response.
    result = JSON.parse(response.body)
  end

  def self.create_access_token(auth_token, auth_secret) # The access token identifies the user making the request.
    @access_token = OAuth::Token.new(auth_token, auth_secret)
  end

  def self.set_http_request(api_call) # Set up Net::HTTP to use SSL, which is required by Twitter.
    http = Net::HTTP.new api_call.host, api_call.port
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    return http
  end

  def self.authorize_request(http, access_token, api_call) # Build the request and authorize it with OAuth.
    request = Net::HTTP::Get.new api_call.request_uri
    request.oauth!(http, @@consumer_key, access_token)
    return request
  end
end
