class CreateOverdueAlerts < ActiveRecord::Migration
  def change
    create_table :overdue_alerts do |t|
      t.integer :admin_id
      t.text :borrow_ids

      t.timestamps
    end
  end
end
