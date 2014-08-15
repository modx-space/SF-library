class RenameCateToUsers < ActiveRecord::Migration
  def change
  	rename_column :users, :cate, :role	
  end
end
