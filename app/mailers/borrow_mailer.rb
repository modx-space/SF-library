class BorrowMailer < ActionMailer::Base
  default from: "minyue.wang@sap.com" # maybe use other email address, like "minerva.book.lib@sap.com"

  def borrow_notification_to_admin borrow
    @borrow = borrow
    @receivers = User.admin
    @subject = "#{borrow.user.name} borrow a #{borrow.book.name}"
    @receivers.each do |user|
      mail(to: user.email, subject: @subject) 
    end 
  end

  def five_days_left_remind borrow
    return if borrow.status != 1 # borrowed

    @borrow = borrow
    @receiver = borrow.user
    @subject = "Please return #{borrow.book.name} within 5 days"
    mail(to: @receiver.email, subject: @subject)
  end
  handle_asynchronously :five_days_left_remind, :run_at => Proc.new { @borrow.should_return_date - 5.day }
end
