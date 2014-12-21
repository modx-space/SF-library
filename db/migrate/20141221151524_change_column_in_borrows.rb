class ChangeColumnInBorrows < ActiveRecord::Migration
  def change
    change_table :borrows do |t|
      t.rename :return_date, :return_at
    end
    change_column :borrows, :return_at, :datetime
  end
end
