# encoding: utf-8
class SessionsController < ApplicationController

  def create
    user = User.find_by(email: params[:user][:email].downcase)
    respond_to do |format|
      if user && user.authenticate(params[:user][:password])
        sign_in user
        format.html { redirect_to library_path }
      else
        flash[:error] = 'Email或密码有误!'
        format.html { redirect_to root_path }
      end
    end  
  end

  def delete
    sign_out
    redirect_to root_path
  end

end