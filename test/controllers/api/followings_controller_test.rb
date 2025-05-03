require "test_helper"

module Api
  module V1
    class FollowingsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:one)
        @target_user = users(:three) # User that's not yet followed
      end

      test "should create a new following relationship" do
        assert_difference("Following.count") do
          post api_v1_user_followings_url(@user), params: { following: { follower_id: @user.id, followed_id: @target_user.id } }, as: :json
        end

        assert_response :created
      end

      test "should return error when trying to follow self" do
        post api_v1_user_followings_url(@user), params: { following: { follower_id: @user.id, followed_id: @user.id } }, as: :json

        assert_response :unprocessable_entity
      end

      test "should remove a following relationship" do
        @user.follow(@target_user)

        assert_difference("Following.count", -1) do
          delete api_v1_user_following_url(@user, @target_user.id), params: { following: { follower_id: @user.id, followed_id: @target_user.id } }, as: :json
        end

        assert_response :success
      end

      test "should return all followed users" do
        get api_v1_user_followings_url(@user), as: :json

        assert_response :success

        response_json = JSON.parse(response.body)
        assert_equal @user.following.count, response_json.size
      end
    end
  end
end
