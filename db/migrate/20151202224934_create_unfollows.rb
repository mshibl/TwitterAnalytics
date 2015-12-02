class CreateUnfollows < ActiveRecord::Migration
  def change
    create_table :unfollows do |t|
      t.integer :unfollower_id
      t.integer :unfollow_event_id

      t.timestamps null: false
    end
  end
end
