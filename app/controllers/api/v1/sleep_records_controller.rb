module Api
  module V1
    class SleepRecordsController < ApplicationController
      before_action :set_user
      before_action :set_sleep_record, only: [ :clock_out ]

      # Clock in operation
      def clock_in
        @sleep_record = @user.sleep_records.build(clock_in_at: Time.current)
        if @sleep_record.save
          render json: format_sleep_records(@user.sleep_records.ordered_by_created), status: :created
        else
          render json: { error: @sleep_record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # Clock out operation
      def clock_out
        if @sleep_record.update(clock_out_at: Time.current)
          render json: format_sleep_records(@user.sleep_records.ordered_by_created), status: :ok
        else
          render json: { error: @sleep_record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # Get all sleep records for a user
      def index
        sleep_records = @user.sleep_records.ordered_by_created
        render json: format_sleep_records(sleep_records), status: :ok
      end

      # Get sleep records of followed users from the previous week
      def following_records
        sleep_records = @user.friends_sleep_records_from_previous_week
        render json: format_sleep_records(sleep_records), status: :ok
      end

      private
      def set_user
        @user = User.find(params[:user_id])
      end

      def set_sleep_record
        @sleep_record = @user.sleep_records.find(params[:id])
      end

      def format_sleep_records(records)
        records.map do |record|
          {
            id: record.id,
            user_id: record.user_id,
            user_name: record.user.name,
            clock_in_at: record.clock_in_at,
            clock_out_at: record.clock_out_at,
            duration_seconds: record.duration_seconds,
            duration_formatted: format_duration(record.duration_seconds),
            created_at: record.created_at
          }
        end
      end

      def format_duration(seconds)
        return nil unless seconds
        hours = seconds / 3600
        minutes = (seconds % 3600) / 60
        "#{hours}h #{minutes}m"
      end

      # Only allow a list of trusted parameters through.
      def sleep_record_params
        params.expect(sleep_record: [ :user_id, :clock_in_at, :clock_out_at ])
      end
    end
  end
end
