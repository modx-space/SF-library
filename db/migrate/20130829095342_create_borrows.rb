class CreateBorrows < ActiveRecord::Migration
  def change
    create_table :borrows do |t|
      t.integer :user_id
      t.integer :book_id
      t.datetime :should_return_date
      t.string :status
      t.integer :is_expired

      t.timestamps
    end
  end
end
