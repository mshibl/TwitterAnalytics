class Follow < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :follow_event, class_name: "History"
end
