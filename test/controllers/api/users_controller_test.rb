require "test_helper"

module Api
  module V1
    class UsersControllerTest < ActionDispatch::IntegrationTest
      setup do
        @first_user = users(:one)
      end

      test "should get index" do
        get api_v1_users_url, as: :json
        assert_response :success
      end

      test "should create user" do
        assert_difference("User.count") do
          post api_v1_users_url, params: { user: { name: "User new" } }, as: :json
        end

        assert_response :created
      end

      test "should not create user" do
        post api_v1_users_url, params: { user: { name: @first_user.name } }, as: :json

        assert_response :unprocessable_entity
        error_message = JSON.parse(response.body)["errors"]
        assert_includes error_message, "Name has already been taken"
      end

      test "should show user" do
        get api_v1_user_url(@first_user), as: :json
        assert_response :success
      end

      test "should update user" do
        patch api_v1_user_url(@first_user), params: { user: { name: @first_user.name } }, as: :json
        assert_response :success
      end

      test "should not update user" do
        patch api_v1_user_url(@first_user), params: { user: { name: "" } }, as: :json
        assert_response :unprocessable_entity
      end

      test "should destroy user" do
        delete api_v1_user_url(@first_user), as: :json

        User.all.reload
        assert_response :no_content
        assert_not User.exists?(@first_user.id)
      end
    end
  end
end
