# encoding: utf-8
class Borrow < ActiveRecord::Base
  extend Enumerize

  enumerize :status, in: [:undelivery, :borrowing, :returned], scope: true
  
  belongs_to :user
  belongs_to :book
  belongs_to :deliver_handler, class_name: 'User', foreign_key: 'deliver_handler_id'
  belongs_to :return_handler, class_name: 'User', foreign_key: 'return_handler_id'

  validate :validate_book_store
  validates :status, presence: true

  # before_create :count_return_date

  #after_save :send_borrow_notification_to_admin
  #after_save :schedule_five_days_left_remind
  
  def self.search(search, page)
    if search != nil
      joins(:book).where('borrows.id like ? or books.name like ? or author like ? or isbn like ? or books.category like ? or press like ? or books.tag like ?',
         "%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%").paginate(page: page, per_page: BOOK_PER_PAGE)
    else
      paginate(page: page, per_page: BOOK_PER_PAGE)
    end
  end

  def self.admin_search(search, page)
    if search != nil
      joins(:book, :user).where('borrows.id like ? or users.name like ? or users.email like ? or users.team like ? or books.name like ? or author like ? or isbn like ? or books.category like ? or press like ? or books.tag like ?',
         "%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%").paginate(page: page, per_page: BOOK_PER_PAGE)
    else
      paginate(page: page, per_page: BOOK_PER_PAGE)
    end
  end

  def validate_book_store
    unless self.book.store >= 0
      errors.add(:base, "#{self.book.name} has no enough store")
    end
  end

  # def count_return_date
  #   self.should_return_date = Time.now + BORROW_PERIOD
  # end
  
  def send_borrow_notification_to_admin
    BorrowMailer.borrow_notification_to_admin(self).deliver
  end

  def schedule_five_days_left_remind
    BorrowMailer.five_days_left_remind(self).deliver
  end
  
  def return_and_shipout_order(return_handler)
    self.status = :returned 
    self.return_at = Time.now
    self.return_handler_id = return_handler.id
    book = self.book
    begin
      message = "归还成功!"
      self.transaction do
        self.save!
        ## if there're orders then pick up the first one to borrow it
        #if order = Order.find_by(book_id: book.id).order(created_at: :desc).limit(1)
        if order = book.orders.find_by(status: :in_queue)
          order.shipout_order
          order_user = order.user
          new_borrow = order_user.borrows.new
          new_borrow.book_id = book.id
          new_borrow.status = :undelivery
          new_borrow.save!
          message = "归还成功，并自动借阅给排队等待的第一位用户#{order_user.name}"
        else 
          book.store = book.store + 1
          book.save!
        end
      end
      send_borrow_notification_to_admin
      return {value: true, message: message}
    rescue Exception => ex
      logger.error "*** transaction abored!"
      logger.error "*** errors: #{ex.message}"
      return {value: false, message: "归还失败!!!"}
    end
  end
end
