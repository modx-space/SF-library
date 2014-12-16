#encoding: utf-8
class BorrowsController < ApplicationController

  before_action :signed_in_user
  load_and_authorize_resource

  def create
  	book = Book.find(params[:book_id])
    already_borrow_book = current_user.borrows.where(book_id: book.id).where("status != '?'", BORROW_STATUSES.index('已归还'))
    if already_borrow_book.size > 0
    	flash[:info] = "你已在使用本书，不可多占资源..."
    else
      if book.store > 0
      	@borrow = current_user.borrows.new
      	@borrow.book_id = params[:book_id]
        @borrow.status = BORROW_STATUSES.index('未出库')
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
          flash[:error] = "借阅失败!"
        end

      else
        # 无库存，可预订
        flash[:notice] = "无库存,可预订!"
      end
    end
    respond_to do |format|
      format.html { redirect_to edit_book_path(book.id) } 
    end
  end

  def deliver
    borrow = Borrow.find(params[:id])
    if borrow.update(status: BORROW_STATUSES.index('借阅中'), 
      should_return_date: Time.now + BORROW_PERIOD)
      flash[:success] = "出库成功!" 
      borrow.schedule_five_days_left_remind
    else
      logger.error borrow.errors
      flash[:error] = "出库失败!!!!"
    end

    respond_to do |format|
      format.html { redirect_to admin_borrowing_path }
    end
  end

  def return
    borrow = Borrow.find(params[:id])
    result = borrow.return_and_shipout_order 
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
    @borrows =  Borrow.where("user_id = :user_id and status != ':status'", 
                      {user_id: current_user.id, status: BORROW_STATUSES.index('已归还')})
                      .paginate(page: page, per_page: BOOK_PER_PAGE)
    
    render_list_page('current_index.html.erb', @borrows.size)

  end
 
  def history_list
    page = params[:page] || 1
    @borrows = Borrow.where("user_id = :user_id and status = ':status'", 
                      {user_id: current_user.id, status: BORROW_STATUSES.index('已归还')})
                      .paginate(page: page, per_page: BOOK_PER_PAGE)
    
    render_list_page('history_index.html.erb', @borrows.size)

  end

  def admin_current
    page = params[:page] || 1
    @borrows = Borrow.where("status != ':status'", {status: BORROW_STATUSES.index('已归还')})
                      .paginate(page: page, per_page: BOOK_PER_PAGE)
    
    render_list_page('current_index.html.erb', @borrows.size)
  end

  def admin_history
    page = params[:page] || 1
    @borrows = Borrow.where("status = ':status'", {status: BORROW_STATUSES.index('已归还')})
                      .paginate(page: page, per_page: BOOK_PER_PAGE)
    
    render_list_page('history_index.html.erb', @borrows.size)
  end

  private 

  def render_list_page (path, size)
    respond_to do |format|
      if size > 0  
        format.html {render path} 
      else
        format.html {render 'helper/no_records.html.erb'}
      end
    end
  end

end
