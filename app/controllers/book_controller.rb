require "book_controller"
class BookController < ApplicationController
  
  before_action :signed_in_user, only: [:new_hot,:index,:borrow,:borrow_current,:borrow_history,:order_current,:order_history]
  
  def new_hot
    books = Book.all
    @books_new = books[0..5]
    @books_hot = books[5...8]
    @books_rec = books[9..11]
    render 'new_hot'
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
  
  def borrow
    book = Book.find_by(id: params[:book_id])
    record = Borrow.find_by(user_id: current_user.id, book_id: params[:book_id], status: "使用中")
    
    respond_to do |format|
      if record
        # 已在使用，不可多借
        flash[:info] = "你已在使用本书，不可多占资源哦..."
        format.js
      else
        if book.available > 0
          borrow = Borrow.new
          borrow.user_id = current_user.id
          borrow.book_id = params[:book_id]
          borrow.should_return_date = Time.new + 2.weeks
          borrow.status = '使用中'
          borrow.is_expired = 0;
        
          if borrow.save
              book.update_attribute(:store, book.store-1)
            flash[:success] = "借阅成功!"
            format.js
          else
            # 借阅失败
            flash[:error] = "借阅失败!"
            format.js
          end
        else
          # 无库存，可预订
          flash[:notice] = "无库存,可预订!"
          format.js
        end
      end
    end
    
  end
  
  def borrow_current
    sql = %Q| select picture,name,isbn,borrows.created_at,
                    should_return_date,is_expired,status
                    from borrows,books
                    where borrows.book_id = books.id
                          and
                          borrows.user_id = #{current_user.id}
            |
    @borrowing = Borrow.paginate_by_sql(sql,page: params[:page], per_page:10)
    render 'borrowing'
  end
  
  def borrow_history
    sql = %Q| select picture,name,isbn,borrows.created_at,
                    borrows.updated_at
                    from borrows,books
                    where borrows.book_id = books.id
                          and
                          borrows.user_id = #{current_user.id}
                          and
                          borrows.status = "已归还"
            |
    @borrowed = Borrow.paginate_by_sql(sql,page: params[:page], per_page:10)
    render 'borrowed'
  end
  
  def order
    book = Book.find_by(id: params[:book_id])
    record = Borrow.find_by(user_id: current_user.id, book_id: params[:book_id], status: "使用中")
    
    respond_to do |format|
      if record
        # 已在使用，无需预订
        flash[:info] = "你已在使用本书，不必预订..."
        format.js
      else
        ordered = Order.find_by(user_id: current_user.id, book_id: params[:book_id], status: "排队中")
        if ordered
          # 已预订，无需再次预订
          flash[:info] = "你已预订过本书，请耐心等候..."
          format.js
        else
          order = Order.new
          order.user_id = current_user.id
          order.book_id = params[:book_id]
          order.status = '排队中'
          records = Order.find(:all,conditions:{book_id: params[:book_id], status: "排队中"})
          if order.save
            book.update_attribute(:store, book.store-1)
            flash[:success] = "预订成功! 你的服务序号为: #{records.count+1} (^_^)"
            format.js
          else
            # 预订失败
            flash[:error] = "预订失败!"
            format.js
          end
        end
      end
    end
    
  end
  
  def order_current
    sql = %Q| select picture,name,isbn,orders.created_at,status,store
                    from orders,books
                    where orders.book_id = books.id
                          and
                          orders.user_id = #{current_user.id}
                          and
                          orders.status = "排队中"
            |
    @ordering = Order.paginate_by_sql(sql,page: params[:page], per_page:10)
    render 'ordering'
  end
  
  def order_history
    sql = %Q| select picture,name,isbn,orders.created_at,orders.updated_at
                    from orders,books
                    where orders.book_id = books.id
                          and
                          orders.user_id = #{current_user.id}
                          and
                          orders.status = "已处理"
            |
    @ordered = Order.paginate_by_sql(sql,page: params[:page], per_page:10)
    render 'ordered'
  end
  
end
