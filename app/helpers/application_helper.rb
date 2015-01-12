# encoding: utf-8
module ApplicationHelper
  def only_show_content
    (['users', 'books'].include?(params[:controller]) &&
     ['edit', 'new', 'create', 'reset_passwd', 'edit_passwd'].include?(params[:action])) ||
      (['orders', 'books'].include?(params[:controller]) && params[:action] == 'show')
  end
end
