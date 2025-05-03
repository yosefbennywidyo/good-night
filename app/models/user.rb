class User < ApplicationRecord
  # Followers relationship
  has_many :active_followings, class_name: "Following", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_followings, class_name: "Following", foreign_key: "followed_id", dependent: :destroy
  has_many :following, through: :active_followings, source: :followed
  has_many :followers, through: :passive_followings, source: :follower

  validates :name, presence: true, uniqueness: true

  def follow(other_user)
    active_followings.create(followed_id: other_user.id) unless self == other_user
  end

  def unfollow(other_user)
    active_followings.find_by(followed_id: other_user.id)&.destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end
end
