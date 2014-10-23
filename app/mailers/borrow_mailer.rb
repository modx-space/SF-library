class BorrowMailer < ActionMailer::Base
  default from: "from@example.com"

  def borrow_notification_to_admin borrow
    @receivers = User.admin
    @borrower = @user
    @subject = "#{borrow.user.name} borrow a #{borrow.book.name}"
    @receivers.each do |user|
      mail(to: user.email, subject: @subject) 
    end 
  end
end
