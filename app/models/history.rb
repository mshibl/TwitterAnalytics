class History < ActiveRecord::Base
  belongs_to :user
  # has_many :unfollows, foreign_key: "unfollow_event_id"
  # has_many :unfollowers, through: :unfollows
  # has_many :follows, foreign_key: "follow_event_id"
  # has_many :followers, through: :follows
  # validates :followers_count, presence: true
end
