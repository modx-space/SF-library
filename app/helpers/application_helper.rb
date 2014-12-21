# encoding: utf-8
module ApplicationHelper
  def only_show_content
    (params[:controller] == 'users' || params[:controller] == 'books') &&
     (params[:action] == 'edit' || params[:action] == 'new') ||
      (params[:controller] == 'orders' && params[:action] == 'show')
  end
end
