class CreateBlacklistUsers < ActiveRecord::Migration
  def change
    create_table :blacklist_users do |t|
      t.integer :user_id
      t.string :fine_book_name
      t.integer :dismiss_handler_id
      t.datetime :dismiss_at

      t.timestamps
    end
  end
end
