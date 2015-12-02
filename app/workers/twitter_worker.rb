class TwitterWorker
    # include Sidekiq::Worker
    # sidekiq_options :queue => :critical
    # sidekiq_options :retry => false

    def perform
      History.create(user_id: 1, followers_count: 22)
    end
    # def perform(user_id)
    #     user = User.find(user_id)

    #     # Creating history record for user:
    #     user_information = Twitter.execute({user: user, request_type: "users/show.json?screen_name=#{user.screen_name}"})
    #     followers_count = user_information["followers_count"]
    #     favorites_count = user_information["favourites_count"]
    #     retweet_count = user_information["status"]["retweet_count"] # This should be removed
    #     History.create(user_id: user_id, followers_count: followers_count, favorites_count: favorites_count, retweet_count: retweet_count)

    #     # Updating user's followers list:
    #     unless user.auth_token == nil
    #         UpdateFollowersListWorker.perform_async(user_id,followers_count)
    #     end
    # end
end
