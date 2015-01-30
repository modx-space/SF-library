class AddInumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :i_number, :string
  end
end
