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

  def order_queue_count
    Order.count(conditions: "status = '#{ORDER_STATUSES.index('排队中')}' and book_id = #{self.id}")
  end

  def borrow_conditions
    borrows = self.borrowing_list 
    results = Array.new
    borrows.each do |borrow|
      hash = {}
      hash[:user_name] = borrow.user.name
      hash[:borrow_date] = borrow.created_at.to_formatted_s(:Y_m_D)
      hash[:expected_date] = borrow.should_return_date != nil ? borrow.should_return_date.to_formatted_s(:Y_m_D) : :undelivery
      results << hash
    end
    results
  end

  def borrowing_list 
    self.borrows.without_status(:returned).order(created_at: :desc)
  end

  def order_conditions
    orders = self.ordering_list
    results = Array.new
    orders.each do |order|
      hash = {}
      hash[:user_name] = order.user.name
      hash[:order_date] = order.created_at.to_formatted_s(:Y_m_D)
      results << hash
    end
    results
  end

  def ordering_list 
    self.orders.where("status = ':status'", {status: BORROW_STATUSES.index('排队中')}).order(created_at: :desc)
  end

  # STATUSES = {
  #   REC => '推荐',
  #   IN => '已买',
  # }

  # def status_name
  #   STATUSES[status]
  # end
end
