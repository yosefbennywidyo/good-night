class AddDeletedAtToUserFollowingSleepRecord < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at

    add_column :followings, :deleted_at, :datetime
    add_index :followings, :deleted_at

    add_column :sleep_records, :deleted_at, :datetime
    add_index :sleep_records, :deleted_at
  end
end
