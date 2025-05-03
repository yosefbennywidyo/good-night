require "test_helper"

class SleepRecordTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @sleep_record = sleep_records(:one)
  end

  test "should belong to user" do
    assert_respond_to @sleep_record, :user
  end

  test "should validate presence of clock_in_at" do
    @sleep_record.clock_in_at = nil
    assert_not @sleep_record.valid?
    assert_includes @sleep_record.errors[:clock_in_at], "can't be blank"
  end

  test "should calculate duration when clock_out_at is set" do
    sleep_record = SleepRecord.create!(
      user: @user,
      clock_in_at: 1.day.ago,
      clock_out_at: 1.day.ago + 8.hours
    )
    assert_equal 8.hours.to_i, sleep_record.duration_seconds
  end

  test "should not calculate duration when clock_out_at is not set" do
    sleep_record = SleepRecord.create!(
      user: @user,
      clock_in_at: 1.day.ago
    )
    assert_nil sleep_record.duration_seconds
  end

  test "scope ordered_by_created should return records in descending order" do
    SleepRecord.delete_all
    record1 = SleepRecord.create!(
      user: @user,
      clock_in_at: 2.days.ago
    )
    record2 = SleepRecord.create!(
      user: @user,
      clock_in_at: 1.day.ago
    )
    records = @user.sleep_records.ordered_by_created
    assert_equal record2, records.first
    assert_equal record1, records.last
  end

  test "scope complete should return only records with clock_out_at" do
    SleepRecord.delete_all
    SleepRecord.create!(
      user: @user,
      clock_in_at: 1.day.ago,
      clock_out_at: 1.day.ago + 8.hours
    )
    SleepRecord.create!(
      user: @user,
      clock_in_at: 2.days.ago,
      clock_out_at: 2.days.ago + 7.hours
    )
    SleepRecord.create!(
      user: @user,
      clock_in_at: 1.hour.ago
    )
    records = @user.sleep_records.complete
    assert_equal 2, records.count
    assert records.all? { |r| r.clock_out_at.present? }
  end

  test "scope from_previous_week should return only records from the previous week" do
    SleepRecord.delete_all
    SleepRecord.create!(
      user: @user,
      clock_in_at: 1.day.ago
    )
    SleepRecord.create!(
      user: @user,
      clock_in_at: 3.days.ago
    )
    SleepRecord.create!(
      user: @user,
      clock_in_at: 8.days.ago
    )
    records = @user.sleep_records.from_previous_week
    assert_equal 2, records.count
    assert records.all? { |r| r.clock_in_at > 1.week.ago }
  end
end
