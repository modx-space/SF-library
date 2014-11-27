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
        @borrow.status = BORROW_STATUES.index('未出库')
        @borrow.is_expired = 0
        if @borrow.save
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

  def borrow_current
    sql = %Q| select picture,name,isbn,borrows.created_at,
                    should_return_date,is_expired,borrows.status
                    from borrows,books
                    where borrows.book_id = books.id
                          and
                          borrows.user_id = #{current_user.id}
    |
    @borrowing = Borrow.paginate_by_sql(sql,page: params[:page], per_page: BOOK_PER_PAGE)

    respond_to do |format|
      format.html {render '_borrowing.html.erb'}

    end

  end


  def borrow_history
    sql = %Q| select picture,name,isbn,borrows.created_at,
                    borrows.updated_at
                    from borrows,books
                    where borrows.book_id = books.id
                          and
                          borrows.user_id = #{current_user.id}
                          and
                          borrows.status = #{BORROW_STATUSES.index('已归还')}
    |
    @borrowed = Borrow.paginate_by_sql(sql,page: params[:page], per_page: BOOK_PER_PAGE)

    respond_to do |format|
      format.html {render '_borrowed.html.erb'}
      format.js {render 'borrowed.js.erb'}
    end
  end

end
