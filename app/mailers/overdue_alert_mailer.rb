class OverdueAlertMailer < ActionMailer::Base
  default from: "DL_536ACDABDF15DB7F9000000F@exchange.sap.corp" # maybe use other email address, like "minerva.book.lib@sap.com"

  def overdue_alert_to_user user,book
    @subject = "超期提醒: 您所借的<#{book.name}>已超期"
    mail(to: user.email, subject: @subject)
  end

  def send_overdue_report_to_admin user, borrow_id_array
    @borrows = Borrow.find borrow_id_array
    @subject = "#{user.display_name}执行了超期邮件提醒"
    @receivers_mail = User.on_board.with_role(:super_admin).pluck(:email)
    @receivers_mail << user.email
    mail(to: @receivers_mail.uniq.join(";"), subject: @subject) 
  end
  
end