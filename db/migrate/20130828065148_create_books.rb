class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :name
      t.string :picture
      t.text :intro
      t.string :author
      t.string :isbn
      t.string :press
      t.date :publish_date
      t.float :price
      t.integer :total
      t.integer :store
      t.integer :available
      t.string :provider

      t.timestamps
    end
  end
end
