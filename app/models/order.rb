# encoding: utf-8
class Order < ActiveRecord::Base
  extend Enumerize
  extend SortUtils

  enumerize :status, in: [:in_queue, :handled, :canceled], scope: true

  belongs_to :user
  belongs_to :book

  validates :status, presence: true

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
end
