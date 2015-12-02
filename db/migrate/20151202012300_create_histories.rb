class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.integer :user_id
      t.integer :followers_count, {default: 0}

      t.timestamps null: false
    end
  end
end
