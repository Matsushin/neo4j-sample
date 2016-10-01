class Friendship < ApplicationRecord
  belongs_to :follow, class_name: "User", foreign_key: :friend_id
  belongs_to :follower, class_name: "User", foreign_key: :user_id
end
