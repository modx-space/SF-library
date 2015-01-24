#encoding: utf-8
class BorrowsController < ApplicationController

  before_action :signed_in_user
  load_and_authorize_resource

  def create
  	book = Book.find(params[:book_id])
    already_borrow_book = current_user.borrows.without_status(:returned).where(book_id: book.id)
    if already_borrow_book.size > 0
    	flash[:info] = "你已在使用本书，不可多占资源..."
    else
      if book.store > 0
      	@borrow = current_user.borrows.new
      	@borrow.book_id = params[:book_id]
        @borrow.status = :undelivery
        begin
          @borrow.transaction do
            @borrow.save!
            book.store = book.store - 1
            book.save!
          end
          flash[:success] = "借阅成功!"
          @borrow.send_borrow_notification_to_admin
        rescue Exception => ex
          logger.error "*** transaction abored!"
          logger.error "*** errors: #{ex.message}"
          flash[:error] = "借阅失败: " << @borrow.errors.full_messages.to_s
        end

      else
        # 无库存，可预订
        flash[:notice] = "无库存,可预订!"
      end
    end
    respond_to do |format|
      format.html { redirect_to :back } 
    end
  end

  def deliver
    borrow = Borrow.find(params[:id])
    if borrow.update(status: :borrowing, 
      should_return_date: Time.now + BORROW_PERIOD,
      deliver_handler_id: current_user.id)
      flash[:success] = "出库成功!" 
      borrow.schedule_five_days_left_remind
    else
      logger.error borrow.errors
      flash[:error] = "出库失败: " << borrow.error.full_messages.to_s
    end

    respond_to do |format|
      format.html { redirect_to admin_borrowing_path }
    end
  end

  def return
    borrow = Borrow.find(params[:id])
    result = borrow.return_and_shipout_order(current_user) 
    if result[:value]
      flash[:success] = result[:message]
    else
      flash[:error] = result[:message]
    end
    respond_to do |format|
      format.html { redirect_to admin_borrowing_path }
    end
  end
  
  def current_list
    page = params[:page] || 1
    @borrows =  Borrow.where("user_id = :user_id and borrows.status != :status", 
                      { user_id: current_user.id, status: :returned })
                      .search(params[:tag], page)
                      
    render_list_page('current_index.html.erb')

  end
 
  def history_list
    page = params[:page] || 1
    @borrows = Borrow.where("user_id = :user_id and borrows.status = :status", 
                      {user_id: current_user.id, status: :returned })
                      .search(params[:tag], page)
    
    render_list_page('history_index.html.erb')

  end

  def admin_current
    page = params[:page] || 1
    @borrows = Borrow.where("borrows.status != :status", {status: :returned })
                      .admin_search(params[:tag], page)
    
    render_list_page('current_index.html.erb')
  end

  def admin_history
    page = params[:page] || 1
    @borrows = Borrow.where("borrows.status = :status", {status: :returned })
                      .admin_search(params[:tag], page)
    
    render_list_page('history_index.html.erb')
  end

  private 

  def render_list_page (path)
    respond_to do |format|     
      format.html {render path} 
    end
  end

end
