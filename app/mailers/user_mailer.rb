class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def overdue_notification user
    @overdue_books = user.overdue_books
    return if @overdue_books.blank?

    @receiver = user
    @subject = "Please return your OVERDUE books"
    mail(to: @receiver.email, subject: @subject)
  end

  def five_days_left_remind user, book
  end
  handle_asynchronously :five_days_left_remind
end
