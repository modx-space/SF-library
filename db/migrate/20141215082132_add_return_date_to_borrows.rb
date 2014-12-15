class AddReturnDateToBorrows < ActiveRecord::Migration
  def change
    change_table :borrows do |t|
      t.remove :is_expired
      t.date :return_date
    end
  end
end
