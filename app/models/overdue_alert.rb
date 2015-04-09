class OverdueAlert < ActiveRecord::Base

  belongs_to :admin, class_name: 'User', foreign_key: 'admin_id'

  def send_overdue_alert_mail user, book
    OverdueAlertMailer.overdue_alert_to_user(user, book).deliver
  end

  def send_overdue_report_mail user, borrow_id_array
    OverdueAlertMailer.delay.send_overdue_report_to_admin(user, borrow_id_array)
  end

  def arrange_send_overdue_alert_mail borrows
    borrows.each do |borrow|
      send_overdue_alert_mail(borrow.user, borrow.book)
    end
  end

  def save_and_send_mail
    begin
      self.transaction do
        borrows = Borrow.where("should_return_date < :now and status = :status",
                                { now: Time.now, status: :borrowing })
        borrow_id_array = borrows.pluck(:id)
        self.borrow_ids = borrow_id_array.join(',')
        self.save!

        admin = User.find self.admin_id
        delay.arrange_send_overdue_alert_mail(borrows.all)
        send_overdue_report_mail(admin, borrow_id_array)
      end
      return {value: :success, message: '邮件已入队列发送'}
    rescue Exception => ex
      logger.error "*** transaction abored!"
      logger.error "*** errors: #{ex.message}"
      return {value: :error, message: "邮件失败!!!"}
    end
  end
end
