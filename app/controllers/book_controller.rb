require "open-uri"
require "json"
class BookController < ApplicationController
  
  before_action :signed_in_user
  
  def new_hot
    books = Book.all
    @books_new = Book.order("created_at DESC")[0..5]
    
    sql = %Q| select picture,name,author
                from borrows,books
                where borrows.book_id = books.id
                group by book_id
            |
    @books_hot = Borrow.find_by_sql(sql)[0..2]
    
    sql = %Q| select id,picture,name,isbn,press,author,recommender,point
                    from books
                    where status = "推荐"
                    order by created_at DESC
            |
    @books_rec = Book.find_by_sql(sql)[0..2]
    
    render 'new_hot'
  end
  
  def index
    # sql = %Q| select * from books where status = "已买" |
    sql = %Q| select * from books |
    @books = Book.paginate_by_sql(sql,page: params[:page], per_page:10)
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
        if book.store > 0
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
                    should_return_date,is_expired,borrows.status
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
    sql = %Q| select picture,name,isbn,orders.created_at,orders.status,store
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
  
  def recommed_list
    sql = %Q| select id,picture,name,isbn,press,author,recommender,point,intro
                    from books
                    where status = "推荐"
            |
    @recommed = Book.paginate_by_sql(sql,page: params[:page], per_page:10)
    render 'recommeds'
  end
  
  def recbook
    render 'recbook'
  end
  
  def fetch
    respond_to do |format|
      uri = URI('https://api.douban.com/v2/book/isbn/'+params[:isbn]);
      begin
        open(uri) do |http|
          response = JSON.parse(http.read)
          @book = {}
          @book[:picture] = response["images"]["large"]
          @book[:isbn] = response["isbn13"]
          @book[:name] = response["title"]
          @book[:author] = response["author"].to_s.delete("[]\"")
          @book[:language] = response["translator"].length > 0 ? "外文" : "中文"
          @book[:cate] = response["tags"][0]["name"]
          @book[:press] = response["publisher"]
          @book[:publish_date] = response["pubdate"]
          @book[:price] = response["price"]
          @book[:intro] = response["summary"].delete("\n")[0,150]+"......"
        end
      rescue 
        @book = {}
        flash[:error] = "请核实ISBN!"
      end
      format.js
    end
  end
  
  def recommend
    if Book.find_by(isbn: params[:book][:isbn])
      flash.now[:warn] = "此书已被推荐!请搜索投票"
    else
      book = Book.new
      book.name = params[:book][:name]
      book.picture = params[:book][:picture]
      book.intro = params[:book][:intro]
      book.author = params[:book][:author]
      book.isbn = params[:book][:isbn]
      book.press = params[:book][:press]
      book.publish_date = params[:book][:publish_date]
      book.language = params[:book][:language]
      book.cate = params[:book][:cate]
      book.price = params[:book][:price]
      book.total = 0
      book.store = 0
      book.point = 0
      book.status = "推荐"
      book.recommender = current_user.name
      book.save
    end
    index 
  end
  
  def vote
    book = Book.find_by(id: params[:book_id])
    record = Vote.find_by(user_id: current_user.id)
    
    respond_to do |format|
      if record
        # 有投票记录
        if record.book_ids.split(",").include?("#{book.id}")
          flash[:info] = "你已为本书投过票,(ˇˍˇ)"
          format.js
        else
          record.update_attribute(:book_ids, "#{record.book_ids},#{book.id}")
          book.update_attribute(:point, book.point+1)
          flash[:success] = "你已投出神圣且重要的一票! O(∩_∩)O"
          format.js
        end
      else
        # 没有投票记录
        vote = Vote.new
        vote.user_id = current_user.id
        vote.book_ids = book.id
        if vote.save
          book.update_attribute(:point, book.point+1)
          flash[:success] = "你已投出神圣且重要的一票! O(∩_∩)O"
          format.js
        else
          flash[:error] = "投票失败!(⊙o⊙)…"
          format.js
        end
      end
    end
  end
  
end
