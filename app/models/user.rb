class User < ActiveRecord::Base
  has_many :relationships
  has_many :followers, through: :relationships
  has_many :unfollows, foreign_key: "unfollower_id"
  has_many :unfollow_events, through: :unfollows
  has_many :follows, foreign_key: "follower_id"
  has_many :follow_events, through: :follows
  has_many :histories

  def self.find_or_create_from_auth_hash(auth_hash)
    user = where(uid: auth_hash[:uid]).first_or_create
    user.update(
      name: auth_hash[:info][:name],
      provider: auth_hash[:provider],
      screen_name: auth_hash[:info][:nickname].downcase,
      auth_token: auth_hash[:credentials][:token],
      auth_secret: auth_hash[:credentials][:secret]
      )
    return user
  end
end
