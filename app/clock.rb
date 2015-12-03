require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  every(30.minutes, 'update records for all users') do
    User.where.not(screen_name: nil).each do |user|
      Twitter.update_records(user.id)
    end
  end

  # every(1.minute, 'test clockwork on heroku') do
  #   Twitter.update_records
  # end

  # every(30.minutes, 'update_all_users_followers_count') do
  # end

  # every(20.minutes, 'track_multiple_twitter_accounts') do
  #   StalkerWorker.perform_async
  # end

  # every(1.hour, 'send_a_user_email') do
  #   User.where.not(email: nil).each do |user|
  #     MailerWorker.perform_async(user.email)
  #   end
  # end
end
