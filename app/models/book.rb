class Book < ActiveRecord::Base
  
  has_many :borrows
  has_many :users, through: :borrows
  has_many :orders
  has_many :user, through: :orders
  
end
