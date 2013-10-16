# encoding: utf-8
class UserController < ApplicationController
  
  before_action :signed_in_user, only: [:index]
  
  def index
    @users = User.paginate(page: params[:page], per_page:10)
    
    respond_to do |format|
      format.js { render 'index.js.erb' }
    end
    
  end
  
  def login
    user = User.find_by(email: params[:user][:email].downcase)
    if user && user.authenticate(params[:user][:password])
      sign_in user
      redirect_to library_path
    else
      flash[:error] = 'Email或密码有误!'
      redirect_to root_path
    end
  end
  
  def create
    user = User.new
    user.name = params[:user][:name]
    user.email = params[:user][:email]
    user.team = params[:user][:team]
    user.cate = params[:user][:cate]
    user.password = 'sf1234'
    user.password_confirmation = 'sf1234'
    if user.save
      flash.now[:success] = '用户创建成功!'
    else
      flash.now[:error] = '用户创建失败!'
    end
    index
    
  end
  
  def modify
    user = User.find(params[:user][:id])
    if user and user.update(name: params[:user][:name], email: params[:user][:email], cate: params[:user][:cate], team: params[:user][:team])
      flash[:success] = "数据更新成功!"
    else
      flash[:error] = '数据更新失败!'
    end
    redirect_to users_path
  end
  
  def delete
    if User.delete(params[:user_id])
      flash.now[:success] = '用户删除成功!'
    else
      flash.now[:error] = '用户删除失败!'
    end
    
    index
    
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
  
end
