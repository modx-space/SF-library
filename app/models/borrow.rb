# encoding: utf-8
class Borrow < ActiveRecord::Base
  extend Enumerize

  enumerize :status, in: [:undelivery, :borrowing, :returned], scope: true
  
  belongs_to :user
  belongs_to :book

  validate :validate_book_store

  # before_create :count_return_date

  #after_save :send_borrow_notification_to_admin
  #after_save :schedule_five_days_left_remind
  
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
  
  def return_and_shipout_order
    self.status = :returned 
    self.return_at = Time.now
    book = self.book
    begin
      message = "归还成功!"
      self.transaction do
        self.save!
        ## if there're orders then pick up the first one to borrow it
        #if order = Order.find_by(book_id: book.id).order(created_at: :desc).limit(1)
        if order = book.orders.find_by(status: ORDER_STATUSES.index('排队中'))
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
      return {value: true, message: "归还失败!!!"}
    end
  end
end
