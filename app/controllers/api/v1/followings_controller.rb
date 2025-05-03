module Api
  module V1
    class FollowingsController < ApplicationController
      before_action :set_target_user, only: [ :create, :destroy ]
      before_action :set_user

      # GET /followings
      def index
        followers = @user.followers

        render json: followers.map { |user| { id: user.id, name: user.name } }, status: :ok
      end

      # POST /followings
      def create
        @following = Following.new(following_params)

        if @following.save!
          render json: @following, status: :created
        else
          render json: @following.errors, status: :unprocessable_entity
        end
      end

      # DELETE /followings/1
      def destroy
        if @user.unfollow(@target_user)
          render json: { message: "Successfully unfollowed user" }, status: :ok
        else
          render json: { error: "Unable to unfollow user" }, status: :unprocessable_entity
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
