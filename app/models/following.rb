class Following < ApplicationRecord
  belongs_to :follower, class_name: "User", counter_cache: :following_count
  belongs_to :followed, class_name: "User", counter_cache: :followers_count

  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validates :follower_id, uniqueness: { scope: :followed_id, message: "You are already following this user." }
  validate :cannot_follow_self

  private

  def cannot_follow_self
    errors.add(:follower_id, "cannot follow yourself") if follower_id == followed_id
  end
end
