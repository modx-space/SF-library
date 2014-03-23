# encoding: utf-8
class Book < ActiveRecord::Base
  
  has_many :borrows
  has_many :users, through: :borrows
  has_many :orders
  has_many :user, through: :orders
  
  validates :store, numericality: { only_integer: true }
  
  def self.search_by_tag(search, page)
            paginate :per_page => 10, :page => page,   
                       :conditions => ['name like ?', "%#{search}%"]
  end
  def self.search(page)
    paginate :per_page => 10, :page => page
  end
  
  
end
