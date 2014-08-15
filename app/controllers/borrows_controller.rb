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
        @borrow.status = BORROW_STATUES.index('未出库')
        @borrow.is_expired = 0
        if @borrow.save
            book.update_attribute(:store, book.store-1)
            flash[:success] = "借阅成功!"
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

end
