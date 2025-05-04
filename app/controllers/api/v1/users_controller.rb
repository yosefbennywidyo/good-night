module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: %i[ show update destroy ]

      # GET /users
      def index
        if params[:per_page].present?
          @users = User.all.page(params[:page]).per(params[:per_page])
        else
          @users = User.all.page(params[:page])
        end

        render jsonapi: @users
      end

      # GET /users/1
      def show
        render jsonapi: @user
      end

      # POST /users
      def create
        @user = User.new(user_params)

        if @user.save
          render jsonapi: @user, status: :created
        else
          render jsonapi_errors: @user.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /users/1
      def update
        if @user.update(user_params)
          render jsonapi: @user
        else
          render jsonapi_errors: @user.errors, status: :unprocessable_entity
        end
      end

      # DELETE /users/1
      def destroy
        @user.destroy!
        head :no_content
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_user
          @user = User.find(params.expect(:id))
        end

        # Only allow a list of trusted parameters through.
        def user_params
          params.expect(user: [ :name ])
        end
    end
  end
end
