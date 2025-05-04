class User < ApplicationRecord
  acts_as_paranoid

  has_many :sleep_records, dependent: :destroy_async
  # Followers relationship
  has_many :active_followings, class_name: "Following", foreign_key: "follower_id", dependent: :destroy_async
  has_many :passive_followings, class_name: "Following", foreign_key: "followed_id", dependent: :destroy_async
  has_many :following, through: :active_followings, source: :followed
  has_many :followers, through: :passive_followings, source: :follower

  validates :name, presence: true, uniqueness: true

  def follow(other_user)
    return if self == other_user

    errors.add(:base, "You are already following #{other_user.name}.") unless following?(other_user)

    following = active_followings.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_followings.find_by(followed_id: other_user.id)&.destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def friends_sleep_records_from_previous_week
    SleepRecord
      .where(user_id: following.select(:id))
      .where(clock_in_at: 1.week.ago..Time.current)
      .where.not(clock_out_at: nil)
      .order(duration_seconds: :desc)
  end

  private

  def self.includes_associations
    includes(:sleep_records).joins(:active_followings, :passive_followings)
  end
end
