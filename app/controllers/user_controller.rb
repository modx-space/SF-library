class UserController < ApplicationController
  
  before_action :signed_in_user, only: [:index]
  
  def index
    @users = User.paginate(page: params[:page], per_page:10)
  end
  
  def login
    user = User.find_by(email: params[:user][:email].downcase)
    if user && user.authenticate(params[:user][:password])
      sign_in user
      redirect_to newhot_path
    else
      flash[:error] = 'Email或密码有误!'
      redirect_to root_path
    end
  end
  
  def create
    user = User.new(params[:user])
    # user.name = params[:user][:name]
   #  user.email = params[:user][:email]
   #  user.team = params[:user][:team]
   #  user.cate = params[:user][:cate]
   #  user.name = params[:user][:name]
   
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
  
end
