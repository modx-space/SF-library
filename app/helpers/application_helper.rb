# encoding: utf-8
module ApplicationHelper
  def only_show_content
    (['users', 'books'].include?(params[:controller]) &&
     ['edit', 'new', 'create', 'reset_passwd', 'edit_passwd', 'update', 'reset', 'update_passwd'].include?(params[:action])) ||
      (['orders', 'books', 'users'].include?(params[:controller]) && params[:action] == 'show')
  end
end
