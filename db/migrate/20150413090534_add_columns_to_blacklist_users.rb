class AddColumnsToBlacklistUsers < ActiveRecord::Migration
  def change
    add_column :blacklist_users, :overdue_borrows, :string
    add_column :blacklist_users, :still_no_return, :string
    add_column :blacklist_users, :status, :string
  end
end
