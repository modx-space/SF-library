# encoding: utf-8
class Order < ActiveRecord::Base
  extend Enumerize

  enumerize :status, in: [:in_queue, :handled, :canceled], scope: true

  belongs_to :user
  belongs_to :book

  validates :status, presence: true

  def self.search(search, page)
    if search != nil
      joins(:book).where('orders.id like ? or books.name like ? or author like ? or isbn like ? or books.category like ? or press like ? or books.tag like ?',
         "%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%").paginate(page: page, per_page: BOOK_PER_PAGE)
    else
      paginate(page: page, per_page: BOOK_PER_PAGE)
    end
  end

  def self.admin_search(search, page)
    if search != nil
      joins(:book, :user).where('orders.id like ? or users.name like ? or users.email like ? or users.team like ? or books.name like ? or author like ? or isbn like ? or books.category like ? or press like ? or books.tag like ?',
         "%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%").paginate(page: page, per_page: BOOK_PER_PAGE)
    else
      paginate(page: page, per_page: BOOK_PER_PAGE)
    end
  end
  
  def shipout_order
    self.status = :handled
    self.save!
  end

  def cancel
    self.status = :canceled
    self.save
  end
end
