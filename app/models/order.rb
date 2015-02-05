# encoding: utf-8
class Order < ActiveRecord::Base
  extend Enumerize
  extend SortUtils

  enumerize :status, in: [:in_queue, :handled, :canceled], scope: true

  belongs_to :user
  belongs_to :book

  validates :status, :book_id, :user_id, presence: true
  validate :order_cannot_duplicate, :order_while_borrow, :user_validation, on: :create

  def self.search(search)
    if search.present?
      joins(:book).where('orders.id like ? or books.name like ? or author like ? or isbn like ? or books.category like ? or press like ? or books.tag like ?',
         "%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%")
    else
      all
    end
  end

  def self.admin_search(search)
    if search.present?
      joins(:book, :user).where('orders.id like ? or users.name like ? or users.email like ? or users.team like ? or books.name like ? or author like ? or isbn like ? or books.category like ? or press like ? or books.tag like ?',
         "%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%")
    else
      all
    end
  end

  def self.sort(sort_type, supported_sort_types)
    if sort_type.present? && supported_sort_types.include?(sort_type.to_sym)
      sort_condition = parse_sort_type(sort_type)
      order(sort_condition)
    else
      all
    end
  end

  def self.current_sort_types
    [:created_at_desc]
  end

  def self.history_sort_types
    [:created_at_desc, :updated_at_desc]
  end
  
  def shipout_order
    self.status = :handled
    self.save!
  end

  def previous_order_count
    Order.where("status = ? and book_id = ? and created_at < ?",
     :in_queue, self.book_id, self.created_at).count
  end

  def cancel
    self.status = :canceled
    self.save
  end

  def order_while_borrow
    return if (self.book_id.nil? || self.user_id.nil?)

    book = Book.find(self.book_id)
    borrow = Borrow.find_by(user_id: self.user_id, book_id: book.id, status: [:borrowing, :undelivery])
    if !borrow.nil?
      errors.add(:base, '您已借阅本书，五天后方可再次预定') if Time.now < (borrow.created_at + 5.days)
    end
  end

  def order_cannot_duplicate
    return if (self.book_id.nil? || self.user_id.nil?)
    
    existed_order = Order.find_by(user_id: self.user_id, book_id: self.book_id, status: :in_queue)
    if !existed_order.nil?
      errors.add(:base, '你已预约此书，请耐心等候...')
    end
  end

  def user_validation
    user = self.user
    unless (msg = user.restrict_total_borrow_order).blank?
      errors.add(:base, msg)
    end
  end

end
