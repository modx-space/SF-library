class AddHandlerToBorrows < ActiveRecord::Migration
  def change
    change_table :borrows do |t|
      t.integer :deliver_handler_id
      t.integer :return_handler_id
    end
    change_table :books do |t|
      t.remove :store_date
    end
  end
end
