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

  def self.update_records(user_id)
    user = User.find(user_id)

    # Creating history record for user:
    user_information = Twitter.execute({user: user, request_type: "users/show.json?screen_name=#{user.screen_name}"})
    followers_count = user_information["followers_count"]
    # favorites_count = user_information["favourites_count"]
    History.create(user_id: user_id, followers_count: followers_count)

    # Updating user's followers list:
    unless user.auth_token == nil
      Twitter.update_followers_list(user_id,followers_count)
    end
  end

  # Get the latest full list of followers from Twitter (up to 75,000 followers only)
  def self.get_full_followers_list(user_id,followers_count)
    user = User.find(user_id)
    num_of_pages = ((followers_count / 5000) + 1)
    cursor = -1
    ordered_followers = []

    num_of_pages.times do
      followers_list = Twitter.execute({user: user, request_type: "followers/ids.json?stringify_ids=true&cursor=#{cursor}&user_id=#{user.uid}"})
      ordered_followers << followers_list["ids"].reverse
      cursor = followers_list["next_cursor"]
    end
    return ordered_followers.flatten!
  end

  def self.update_followers_list(user_id,followers_count)
    followership_info = Twitter.get_followers_and_unfollowers(user_id,followers_count)
    event_id = History.where(user_id: user_id).order(:created_at).last.id

    # Add new followers
    followership_info[:new_followers].each do |uid|
      follower = User.find_by(uid: uid)
      follower ||= User.create(uid: uid)
      Relationship.where(user_id: user_id).find_by(follower_id: follower.id) || Relationship.create(user_id: user_id, follower_id: follower.id)
      Follow.create(follower_id: follower.id, follow_event_id: event_id)
    end

    # Delete unfollowers
    followership_info[:unfollowers].each do |uid|
      unfollower = user.find_by(uid: uid)
      Relationship.where(user_id: user_id).find_by(follower_id: unfollower.id).delete
      Unfollow.create(unfollower_id: unfollower.id, unfollow_event_id: event_id)
    end
  end

  # Get a hash of followers and unfollowers since the last recorded history of a given user
  def self.get_followers_and_unfollowers(user_id,followers_count)
    user = User.find(user_id)

    old_list_of_followers = user.followers.select(:uid).map(&:uid)
    new_list_of_followers = Twitter.get_full_followers_list(user.id,followers_count)

    followership_info = {
      new_followers: (new_list_of_followers - old_list_of_followers),
      unfollowers: (old_list_of_followers - new_list_of_followers)
    }
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
