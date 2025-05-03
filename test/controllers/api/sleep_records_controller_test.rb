require "test_helper"

module Api
  module V1
    class SleepRecordsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @first_user   = users(:one)
        @second_user  = users(:two)
        @sleep_record = sleep_records(:one)
      end
      test "should create a new sleep record" do
        assert_difference("SleepRecord.count") do
          post clock_in_api_v1_user_sleep_records_url(@first_user), as: :json
        end

        assert_response :created
        response_json = JSON.parse(response.body)
        assert_equal @first_user.id, response_json.first["user_id"]
      end
      test "should update an existing sleep record with clock_out_at" do
        post clock_out_api_v1_user_sleep_record_url(@first_user, @sleep_record), as: :json

        assert_response :success
        @sleep_record.reload
        assert_not_nil @sleep_record.clock_out_at
        assert @sleep_record.duration_seconds > 0
      end
      test "should return all sleep records for a user" do
        get api_v1_user_sleep_records_url(@first_user), as: :json

        assert_response :success
        response_json = JSON.parse(response.body)
        assert_equal @first_user.sleep_records.count, response_json.size
      end
      test "should return sleep records from followed users from the previous week" do
        SleepRecord.destroy_all
        @first_user.follow(@second_user)

        # Create sleep records for followed users
        SleepRecord.create!(
          user: @second_user,
          clock_in_at: 2.days.ago,
          clock_out_at: 2.days.ago + 8.hours
        )

        get following_records_api_v1_user_sleep_records_url(@first_user), as: :json

        assert_response :success
        response_json = JSON.parse(response.body)
        assert_equal 1, response_json.size
      end
    end
  end
end
