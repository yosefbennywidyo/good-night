module Api
  module V1
    class FollowingsController < ApplicationController
      before_action :set_target_user, only: [ :create, :destroy ]
      before_action :set_user

      # GET /followings
      def index
        if params[:per_page].present?
          @followers = @user.followers.page(params[:page]).per(params[:per_page])
        else
          @followers = @user.followers.page(params[:page])
        end

        render jsonapi: @followers, cache: Rails.cache
      end

      # POST /followings
      def create
        @following = Following.new(following_params)

        if @following.save!
          render jsonapi: @following, status: :created
        else
          render jsonapi_errors: @following.errors, status: :unprocessable_entity
        end
      end

      # DELETE /followings/1
      def destroy
        if @user.unfollow(@target_user)
          render jsonapi: { message: "Successfully unfollowed user" }, status: :ok
        else
          render jsonapi_errors: { error: "Unable to unfollow user" }, status: :unprocessable_entity
        end
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_user
          @user = User.find(params.expect(:user_id))
        end

        def set_target_user
          @target_user = User.find(following_params[:followed_id])
        end

        # Only allow a list of trusted parameters through.
        def following_params
          params.expect(following: [ :follower_id, :followed_id ])
        end
    end
  end
end
