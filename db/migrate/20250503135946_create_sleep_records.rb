class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :clock_in_at, null: false
      t.datetime :clock_out_at
      t.integer :duration_seconds

      t.timestamps
    end

    add_index :sleep_records, :clock_in_at
    add_index :sleep_records, :clock_out_at
    add_index :sleep_records, :duration_seconds
  end
end
