# encoding: utf-8
class Book < ActiveRecord::Base
  
  has_many :borrows
  has_many :users, through: :borrows
  has_many :orders
  has_many :users, through: :orders
  
  validates :store, numericality: { only_integer: true }
  
  def self.search_by_tag(search, page)
            paginate :per_page => BOOK_PER_PAGE, :page => page,   
                       :conditions => ['name like ? or author like ? or isbn like ?',
				 "%#{search}%","%#{search}%","%#{search}%"]
  end
  def self.search(page)
    paginate :per_page => BOOK_PER_PAGE, :page => page
  end

  # STATUSES = {
  #   REC => '推荐',
  #   IN => '已买',
  # }

  # def status_name
  #   STATUSES[status]
  # end
end
