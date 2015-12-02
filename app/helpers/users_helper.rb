module UsersHelper
  def self.convert_timestamps(datetime)
    milliseconds = datetime.to_f * 1000
  end

  def get_user_info(screen_name)
    requestor = User.find(session[:user_id])

    retrieved_information = Twitter.execute({user: requestor, request_type:"users/show.json?screen_name=#{screen_name}"})

    user_information = {
      profile_picture: retrieved_information["profile_image_url"].gsub('_normal', ''),
      num_tweets: retrieved_information["statuses_count"],
      num_following: retrieved_information["friends_count"],
      screen_name: screen_name,
      user_id: User.find_by(screen_name: screen_name)
    }
  end

  def self.get_chart(user)
    history = History.where(["user_id = ?", user.id]).order(:created_at)
    @data_changes = {}
    @xData = []
    @followers_record = []
    @favorites = []
    @retweets = []

    history.each do |record|
      # Get new followers associated to this record
      new_followers_ids = record.followers.select(:uid).map(&:uid)
      new_followers = []
      unless new_followers_ids.empty?
        new_followers_ids.each_slice(100) do |slice|
          new_followers_res = Twitter.execute({user: user, request_type: "users/lookup.json?user_id=#{slice.join(',')}"})
          new_followers_res.each{|follower| new_followers << {screen_name: follower["screen_name"], photo: follower["profile_image_url"]}}
        end
      end
      new_followers.flatten!

      # Get new unfollowers associated to this record
      unfollowers_ids = record.unfollowers.select(:uid).map(&:uid)
      unfollowers = []
      unless unfollowers_ids.empty?
        unfollowers_ids.each_slice(100) do |slice|
          unfollowers_res = Twitter.execute({user: user, request_type: "users/lookup.json?user_id=#{slice.join(',')}"})
          unfollowers_res.each{|follower| unfollowers << {screen_name: follower["screen_name"], photo: follower["profile_image_url"]}}
        end
      end
      unfollowers.flatten!

      # Storing data that will be used to populate the main graph & tooltips & the (followers vs. unfollowers) table
      time = UsersHelper.convert_timestamps(record.created_at)
      @xData << time
      @followers_record << record.followers_count
      # @favorites << record.favorites_count
      # @retweets << record.retweet_count
      @data_changes[time] = {new_followers: new_followers, unfollowers: unfollowers}
    end

    # return [@xData.to_json, @followers_record.to_json, @favorites.to_json, @retweets.to_json, @data_changes.to_json]
    return [@xData.to_json, @followers_record.to_json, @favorites.to_json, @data_changes.to_json]
  end

  def self.get_tweet_collection(user)
    tweets_array = []
    response = Twitter.execute({user: user, request_type: "statuses/user_timeline.json?count=200&screen_name=#{user.screen_name}"})
    last_id = response[-1]["id"]
    tweets_array << response
    15.times do
    response = Twitter.execute({user: user, request_type:"statuses/user_timeline.json?count=200&max_id=#{last_id}&screen_name=#{user.screen_name}"})
      if last_id == response[-1]["id"]
        break
      else
        last_id = response[-1]["id"]
        tweets_array << response
      end
    end

    tweets_array.flatten!
    condensed_tweets = []
    tweets_array.each do |tweet|
      date = DateTime.parse(tweet["created_at"])
      date = date.strftime('%Q').to_f #converts to milliseconds
      condensed_tweets << [tweet["id_str"], date]
    end
    condensed_tweets
  end

  def self.get_matching_tweets(user, timestamp)
    tweets = UsersHelper.get_tweet_collection(user)
    thirty_min_ago = timestamp - 1800000
    collection = tweets.select do |tweet|
      tweet[1].to_f >= thirty_min_ago && tweet[1].to_f <= timestamp
    end
    tweet_ids = []
    collection.each {|tweet| tweet_ids << tweet[0]}
    tweet_ids
  end
end
