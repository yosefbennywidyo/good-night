class SleepRecord < ApplicationRecord
  acts_as_paranoid

  belongs_to :user, counter_cache: :sleep_records_count
  validates :clock_in_at, presence: true

  # Update duration when clocking out
  before_save :calculate_duration, if: :will_save_change_to_clock_out_at?
  scope :ordered_by_created, -> { order(created_at: :desc) }
  scope :complete, -> { where.not(clock_out_at: nil) }
  scope :from_previous_week, -> { where(clock_in_at: 1.week.ago..Time.current) }

  private

  def calculate_duration
    if clock_out_at.present? && clock_in_at.present?
      self.duration_seconds = (clock_out_at - clock_in_at).to_i
    end
  end
end
