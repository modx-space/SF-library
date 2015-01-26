class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :building, :string
    add_column :users, :office, :string
    add_column :users, :seat, :integer
    add_column :users, :sf_email, :string
  end
end
