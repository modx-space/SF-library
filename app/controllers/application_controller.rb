class ApplicationController < ActionController::Base
  include UserHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  after_action :show_flash
  
  private
 
    def show_flash
      # only run this in case it's an Ajax request.
      return unless request.xhr?
      response.headers['X-Message'] = flash_message
      response.headers["X-Message-Type"] = flash_type.to_s

      flash.discard # don't want the flash to appear when you reload page
    end

    def flash_message
      [:error, :success, :warn, :info].each do |type|
        return flash[type] unless flash[type].blank?
      end
    end

    def flash_type
      [:error, :success, :warn, :info].each do |type|
        return type unless flash[type].blank?
      end
  end
end
