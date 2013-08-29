class UserController < ApplicationController
  
  def create
    user = User.find_by(email: params[:user][:email].downcase)
    if user
      sign_in user
      redirect_to book_index_path
    else
      flash[:error] = 'Email或密码有误!'
      redirect_to root_path
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
  
end

# && user.authenticate(params[:user][:password])
