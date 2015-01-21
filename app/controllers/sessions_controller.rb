# encoding: utf-8
class SessionsController < ApplicationController

  def create
    user = User.on_board.find_by(email: params[:user][:email].downcase)
    if user.nil? && /@successfactors.com/.match(params[:user][:email].downcase)
      user = User.on_board.find_by(sf_email: params[:user][:email].downcase)
    end
    respond_to do |format|
      if user.nil?
        flash[:error] = '邮箱不存在，请联系管理员'
        format.html { redirect_to root_path }
      else
        if user.authenticate(params[:user][:password])
          sign_in user
          format.html { redirect_to library_path }
        else
          flash[:error] = '密码有误!'
          format.html { redirect_to root_path }
        end
      end
    end  
  end

  def delete
    sign_out
    redirect_to root_path
  end

end