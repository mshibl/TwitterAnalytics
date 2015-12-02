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
end
