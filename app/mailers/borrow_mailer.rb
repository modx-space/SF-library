class BorrowMailer < ActionMailer::Base
  default from: "DL_536ACDABDF15DB7F9000000F@exchange.sap.corp" # maybe use other email address, like "minerva.book.lib@sap.com"

  def borrow_notification_to_admin borrow
    @book = borrow.book
    @user = borrow.user
    @receivers = User.on_board.with_role(:super_admin, :admin)
    @subject = "等待出库: #{borrow.user.name} 借阅了<#{borrow.book.name}>"
    emails = @receivers.collect(&:email).join(";")
    mail(to: emails, subject: @subject)     
  end

  def deliver_notification_to_reader borrow
    @book = borrow.book
    @deliver_handler = borrow.deliver_handler
    @receiver = borrow.user
    @subject = "已出库: 您所借的<#{@book.name}>已由 #{@deliver_handler.name} 出库"
    mail(to: @receiver.email, subject: @subject) 
  end

  def return_notification_to_reader borrow
    @book = borrow.book
    @return_handler = borrow.return_handler
    @receiver = borrow.user
    @subject = "已归还: 您所借的<#{@book.name}>已由 #{@return_handler.name} 归还"
    mail(to: @receiver.email, subject: @subject) 
  end

  def five_days_left_remind borrow
    return if borrow.status != :borrowing.to_s # borrowed

    @borrow = borrow
    @receiver = borrow.user
    @subject = "还书提醒: 您所借的<#{borrow.book.name}>将在3天后到期"
    mail(to: @receiver.email, subject: @subject)
  end
  #handle_asynchronously :five_days_left_remind, :run_at => Proc.new { Time.now + 60}#BORROW_PERIOD - 3.day
end
