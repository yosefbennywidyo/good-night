require "test_helper"

class FollowingTest < ActiveSupport::TestCase
  def setup
    @user1 = users(:one)
    @user2 = users(:two)
    @following = followings(:one_follows_two)
  end

  test "should belong to follower and followed" do
    assert_respond_to @following, :follower
    assert_respond_to @following, :followed
  end

  test "should validate presence of follower_id and followed_id" do
    following = Following.new
    assert_not following.valid?
    assert_includes following.errors[:follower_id], "can't be blank"
    assert_includes following.errors[:followed_id], "can't be blank"
  end

  test "should validate uniqueness of follower_id scoped to followed_id" do
    duplicate_following = Following.new(
    follower: @following.follower,
    followed: @following.followed
    )
    assert_not duplicate_following.valid?
  end

  test "should not allow following yourself" do
    following = Following.new(follower: @user1, followed: @user1)
    assert_not following.valid?
    assert_includes following.errors[:follower_id], "cannot follow yourself"
  end
end
