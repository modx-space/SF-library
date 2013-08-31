class BookController < ApplicationController
  
  before_action :signed_in_user, only: [:new_hot,:index,:borrow_current,:borrow_history,:order_current,:order_history]
  
  def new_hot
    books = Book.all
    @books_new = books[0..5]
    @books_hot = books[5...8]
    @books_rec = books[9..11]
    render 'book_home'
  end
  
  def index
    @books = Book.paginate(page: params[:page], per_page:10)
    if params[:page]
      @page = params[:page]
    else
      @page = 1
    end
    render 'index'
  end
  
  def borrow_current
    sql = %Q| select picture,name,isbn,borrows.created_at,
                    should_return_date,is_expired,status
                    from borrows,books
                    where borrows.book_id = books.id
                          and
                          borrows.user_id = 1
            |
    @borrowing = Borrow.paginate_by_sql(sql,page: params[:page], per_page:3)
    render 'borrowing'
  end
  
  def borrow_history
    sql = %Q| select picture,name,isbn,borrows.created_at,
                    borrows.updated_at
                    from borrows,books
                    where borrows.book_id = books.id
                          and
                          borrows.user_id = 1
            |
    @borrowed = Borrow.paginate_by_sql(sql,page: params[:page], per_page:3)
    render 'borrowed'
  end
  
  def order_current
    sql = %Q| select picture,name,isbn,orders.created_at,status
                    from orders,books
                    where orders.book_id = books.id
                          and
                          orders.user_id = 1
            |
    @ordering = Order.paginate_by_sql(sql,page: params[:page], per_page:3)
    render 'ordering'
  end
  
  def order_history
    sql = %Q| select picture,name,isbn,orders.created_at,orders.updated_at
                    from orders,books
                    where orders.book_id = books.id
                          and
                          orders.user_id = 1
            |
    @ordered = Order.paginate_by_sql(sql,page: params[:page], per_page:3)
    render 'ordered'
  end
  
end
