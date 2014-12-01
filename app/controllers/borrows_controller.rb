class BorrowsController < ApplicationController

  before_action :signed_in_user
  load_and_authorize_resource

  def create
  	book = Book.find(params[:book_id])
    record = Borrow.find_by(user_id: current_user.id, book_id: params[:id], status: "使用中")
    if record
    	flash[:info] = "你已在使用本书，不可多占资源..."
    else
      if book.store > 0
      	@borrow = current_user.borrows.new
      	@borrow.book_id = params[:book_id]
        @borrow.should_return_date = Time.new + 2.weeks
        @borrow.status = BORROW_STATUSES.index('未出库')
        @borrow.is_expired = 0
        if @borrow.save
            book.update_attribute(:store, book.store-1)
            flash[:success] = "借阅成功!"
            BorrowMailer.borrow_notification_to_admin(@borrow).deliver
        else
            # 借阅失败
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
  
  def borrow_current
    page = params[:page] || 1
    @borrows =  Borrow.where("user_id = :user_id and status != ':status'", 
                      {user_id: current_user.id, status: BORROW_STATUSES.index('已归还')})
                      .paginate(page: page, per_page: BOOK_PER_PAGE)
    
    respond_to do |format|
      format.html {render 'index.html.erb'}

    end
    
  end
  
  
  def borrow_history
    page = params[:page] || 1
    @borrows = Borrow.where("user_id = :user_id and status = ':status'", 
                      {user_id: current_user.id, status: BORROW_STATUSES.index('已归还')})
                      .paginate(page: page, per_page: BOOK_PER_PAGE)
    
    respond_to do |format|
      format.html {render 'index.html.erb'}
    end
    
  end

end
