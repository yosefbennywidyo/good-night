require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @first_user   = users(:one)
    @second_user  = users(:two)
    @third_user   = users(:three)
  end

  test "should have associations" do
    assert_respond_to @first_user, :sleep_records
    assert_respond_to @first_user, :active_followings
    assert_respond_to @first_user, :passive_followings
    assert_respond_to @first_user, :following
    assert_respond_to @first_user, :followers
  end

  test "should validate presence of name" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should create a following relationship" do
    assert_difference("Following.count") do
      @third_user.follow(@first_user)
    end
  end

  test "should not allow following yourself" do
    assert_no_difference("Following.count") do
      @first_user.follow(@first_user)
    end
  end

  test "should remove a following relationship" do
    @first_user.follow(@second_user)
    assert_difference("Following.count", -1) do
      @first_user.unfollow(@second_user)
    end
  end

  test "should check if user is following another user" do
    @first_user.follow(@second_user)
    assert @first_user.following?(@second_user)
  end

  test "should get friends sleep records from previous week" do
    SleepRecord.destroy_all
    @first_user.follow(@second_user)
    @first_user.follow(@third_user)
    # Create sleep records
    SleepRecord.create!(
      user: @second_user,
      clock_in_at: 2.days.ago,
      clock_out_at: 2.days.ago + 8.hours
    )
    SleepRecord.create!(
      user: @third_user,
      clock_in_at: 3.days.ago,
      clock_out_at: 3.days.ago + 6.hours
    )

    records = @first_user.friends_sleep_records_from_previous_week
    assert_equal 2, records.count
    assert_equal @second_user.id, records.first.user_id # Longer sleep duration comes first
  end
end
