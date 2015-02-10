# encoding: utf-8
class Borrow < ActiveRecord::Base
  extend Enumerize
  extend SortUtils

  enumerize :status, in: [:undelivery, :borrowing, :returned], scope: true
  
  belongs_to :user
  belongs_to :book
  belongs_to :deliver_handler, class_name: 'User', foreign_key: 'deliver_handler_id'
  belongs_to :return_handler, class_name: 'User', foreign_key: 'return_handler_id'

  validate :cannot_be_duplicate, on: :create
  validate :user_validation, :validate_book_store, on: :create, if: "skip_user_check.nil?"
  validates :status, presence: true

  attr_accessor :skip_user_check
  
  def self.search(search)
    if search.present?
      joins(:book).where('borrows.id like ? or books.name like ? or author like ? or isbn like ? or books.category like ? or press like ? or books.tag like ?',
         "%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%")
    else
      all
    end
  end

  def self.admin_search(search)
    if search.present?
      joins(:book, :user).where('borrows.id like ? or users.name like ? or users.building like ? or users.office like ? or books.name like ? or author like ? or isbn like ? or books.category like ? or press like ? or books.tag like ?',
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
    [:should_return_date_desc, :status_desc]
  end

  def self.admin_management_sort_types
    [:should_return_date_desc, :created_at_desc, :book_id_asc]
  end

  def self.history_sort_types
    [:should_return_date_desc, :return_at_desc]
  end

  # def count_return_date
  #   self.should_return_date = Time.now + BORROW_PERIOD
  # end
  
  def send_borrow_notification_to_admin
    BorrowMailer.borrow_notification_to_admin(self).deliver
  end

  def send_deliver_nofification_to_reader
    BorrowMailer.deliver_notification_to_reader(self).deliver
  end

  def send_return_notification_to_reader
    BorrowMailer.return_notification_to_reader(self).deliver
  end

  def schedule_five_days_left_remind
    BorrowMailer.delay(run_at: (BORROW_PERIOD - 3.day).from_now).five_days_left_remind(self)
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
          new_borrow.skip_user_check = true
          new_borrow.save!
          message = "归还成功，并自动借阅给排队等待的第一位用户#{order_user.name}"
        else 
          book.store = book.store + 1
          book.save!
        end
      end
      send_return_notification_to_reader
      return {value: true, message: message}
    rescue Exception => ex
      logger.error "*** transaction abored!"
      logger.error "*** errors: #{ex.message}"
      return {value: false, message: "归还失败!!!"}
    end
  end

  private

    def user_validation
      user = self.user
      unless (msg = user.restrict_total_borrow_order).blank?
        errors.add(:base, msg)
      end
    end

    def cannot_be_duplicate
      return if self.book_id.nil? || self.user_id.nil?

      existed_borrow = Borrow.find_by(user_id: self.user_id, book_id: self.book_id, status: [:borrowing, :undelivery])
      unless existed_borrow.nil?
        errors[:base] << "你已在借阅本书，不可多占资源"
      end
    end

    def validate_book_store
      unless self.book.store > 0
        errors.add(:base, "无库存,可预订!")
      end
    end

end
