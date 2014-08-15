class ChangeToBooks < ActiveRecord::Migration
  def change
  	change_table :books do |t|
	  t.remove :recommender, :status
	  t.date :store_date
	  t.rename :cate, :category
	end
  end
end
