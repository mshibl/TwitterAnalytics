module UsersHelper
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
      @favorites << record.favorites_count
      # @retweets << record.retweet_count
      @data_changes[time] = {new_followers: new_followers, unfollowers: unfollowers}
    end

    # return [@xData.to_json, @followers_record.to_json, @favorites.to_json, @retweets.to_json, @data_changes.to_json]
    return [@xData.to_json, @followers_record.to_json, @favorites.to_json, @data_changes.to_json]
  end
end
