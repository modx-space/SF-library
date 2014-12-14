# encoding: utf-8
class Borrow < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :book

  validate :validate_book_store

  before_create :count_return_date

  #after_save :send_borrow_notification_to_admin
  #after_save :schedule_five_days_left_remind

  def validate_book_store
    unless self.book.store >= 0
      errors.add(:base, "#{self.book.name} has no enough store")
    end
  end

  def count_return_date
    self.should_return_date = Time.now + BORROW_PERIOD
  end
  
  # def send_borrow_notification_to_admin
  #   BorrowMailer.borrow_notification_to_admin(self).deliver
  # end

  # def schedule_five_days_left_remind
  #   BorrowMailer.five_days_left_remind(self).deliver
  # end
end
