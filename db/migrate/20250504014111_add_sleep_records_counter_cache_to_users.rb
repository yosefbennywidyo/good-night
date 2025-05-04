class AddSleepRecordsCounterCacheToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :sleep_records_count, :integer
  end
end
