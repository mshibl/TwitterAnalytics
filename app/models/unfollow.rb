class Unfollow < ActiveRecord::Base
  belongs_to :unfollower, class_name: "User"
  belongs_to :unfollow_event, class_name: "History"
end
