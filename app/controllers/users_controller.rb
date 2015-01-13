# encoding: utf-8
class UsersController < ApplicationController
  
  before_action :signed_in_user, only: [:index]
  load_and_authorize_resource
  
  def index
    page = params[:page] || 1
    @users = User.search(params[:tag], page)
    respond_to do |format|
      format.html
    end
    
  end
  
  def create
    user = User.new
    user.name = params[:user][:name]
    user.email = params[:user][:email]
    user.team = params[:user][:team]
    user.role = params[:user][:role]
    user.password = DEFAULT_PASSWORD
    user.password_confirmation = DEFAULT_PASSWORD

    user_temp = User.find_by(email: params[:user][:email])
    if user_temp
      flash[:error] = '用户已存在！'
    else
      if user.save
        flash[:success] = '用户创建成功!'
      else
        flash[:error] = '用户创建失败!' << user.errors.full_messages.to_s
      end
    end

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end   
  end

  def show
    if current_user.has_admin_authe && params[:admin] == 'true'
      @admin_page = true
    end
    @user = User.find(params[:id])
    respond_to do |format|
      format.html 
    end
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:user][:id])
    if current_user.super_admin?
      result = @user.update(admin_update_params)
    else
      result = @user.update(update_params)
    end
    if result
      flash[:success] = "更新成功!"
    else
      flash[:error] = '更新失败!' << @user.errors.full_messages.to_s
    end
    respond_to do |format|
      format.html { redirect_to edit_user_path(@user.id) }
    end
    
  end
  
  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:success] = '删除成功。'  
    else
      flash[:error] = '用户删除失败!' << @user.errors.full_messages.to_s
    end
    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end
  
  def reset_passwd
    @user = User.find(params[:id])
  end

  def edit_passwd
    @user = User.find(params[:id])
  end

  def reset
    @user = User.find(params[:id])
    @user.password = params[:new_password]
    @user.password_confirmation = params[:confirm_password]
    if @user.save
      flash[:success] = '密码修改成功'
    else
      flash[:error] = '密码修改失败'<< @user.errors.full_messages.to_s
    end
    respond_to do |format|
      format.html { redirect_to :back}
    end
  end

  def update_passwd
    @user = User.find(params[:id])
    if @user.authenticate(params[:old_password])
      @user.password = params[:new_password]
      @user.password_confirmation = params[:confirm_password]
      if @user.save
        flash[:success] = '密码修改成功'
      else
        flash[:error] = '密码修改失败'<< @user.errors.full_messages.to_s
      end
    else
      flash[:error] = '原密码错误'
    end  
    
    respond_to do |format|
      format.html { redirect_to :back}
    end
  end
  
  private
    # Using a private method to encapsulate the permissible parameters is
    # just a good pattern since you'll be able to reuse the same permit
    # list between create and update. Also, you can specialize this method
    # with per-user checking of permissible attributes.
    def update_params
      params.require(:user).permit(:name,:team, :password, :password_confirmation)
    end

    def admin_update_params
      params.require(:user).permit(:email, :role, :name, :team, :password, :password_confirmation)
    end
end
