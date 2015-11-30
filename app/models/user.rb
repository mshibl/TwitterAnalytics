class User < ActiveRecord::Base
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
