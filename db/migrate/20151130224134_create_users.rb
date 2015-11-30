class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :auth_token
      t.string :auth_secret
      t.string :provider
      t.string :name
      t.string :screen_name
      t.string :uid
      t.string :email

      t.timestamps null: false
    end
  end
end
