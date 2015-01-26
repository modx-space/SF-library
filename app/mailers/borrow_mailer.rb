class BorrowMailer < ActionMailer::Base
  default from: "DL_536ACDABDF15DB7F9000000F@exchange.sap.corp" # maybe use other email address, like "minerva.book.lib@sap.com"

  def borrow_notification_to_admin borrow
    @book = borrow.book
    @user = borrow.user
    @receivers = User.on_board.with_role(:super_admin, :admin)
    @subject = "等待出库: #{borrow.user.name} 借阅了 <#{borrow.book.name}>"
    emails = @receivers.collect(&:email).join(";")
    mail(to: emails, subject: @subject)     
  end

  def five_days_left_remind borrow
    return if borrow.status != :borrowing # borrowed

    @borrow = borrow
    @receiver = borrow.user
    @subject = "Please return #{borrow.book.name} within 5 days"
    mail(to: @receiver.email, subject: @subject)
  end
  handle_asynchronously :five_days_left_remind, :run_at => Proc.new { Time.now + BORROW_PERIOD - 3.day }
end
