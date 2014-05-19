# encoding: utf-8
require "open-uri"
require "json"
class BooksController < ApplicationController
  
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
    
  end
  
  def index
    page = params[:page] || 1
    sql = %Q| select * from books where status = "已买" |
    if params[:tag] != nil
      @books = Book.search_by_tag(params[:tag], page).paginate(page: page, per_page: 10)
    else
      @books = Book.search(page).paginate(page: page, per_page: 10)
    end

    respond_to do |format|
      format.html# {render '_index.html.erb'}
      #format.js { render 'index.js.erb' }
    end
    
  end
  
  def borrow
    binding.pry
    book = Book.find_by(id: params[:book_id])
    record = Borrow.find_by(user_id: current_user.id, book_id: params[:book_id], status: "使用中")
    if record
      # 已在使用，不可多借
      flash.now[:info] = "你已在使用本书，不可多占资源哦..."
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
          flash.now[:success] = "借阅成功!"
        else
          # 借阅失败
          flash.now[:error] = "借阅失败!"
        end
      else
        # 无库存，可预订
        flash.now[:notice] = "无库存,可预订!"
      end
    end
    index
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
    
    respond_to do |format|
      format.html {render '_borrowing.html.erb'}
      format.js {render 'borrowing.js.erb'}
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
                          borrows.status = "已归还"
            |
    @borrowed = Borrow.paginate_by_sql(sql,page: params[:page], per_page:10)
    
    respond_to do |format|
      format.js {render 'borrowed.js.erb'}
    end
    
  end
  
  def order
    book = Book.find_by(id: params[:book_id])
    record = Borrow.find_by(user_id: current_user.id, book_id: params[:book_id], status: "使用中")
    if record
      # 已在使用，无需预订
      flash.now[:info] = "你已在使用本书，不必预订..."
    else
      ordered = Order.find_by(user_id: current_user.id, book_id: params[:book_id], status: "排队中")
      if ordered
        # 已预订，无需再次预订
        flash.now[:info] = "你已预订过本书，请耐心等候..."
      else
        order = Order.new
        order.user_id = current_user.id
        order.book_id = params[:book_id]
        order.status = '排队中'
        records = Order.find(:all,conditions:{book_id: params[:book_id], status: "排队中"})
        if order.save
          book.update_attribute(:store, book.store-1)
          flash.now[:success] = "预订成功! 你的服务序号为: #{records.count+1} (^_^)"
        else
          # 预订失败
          flash.now[:error] = "预订失败!"
        end
      end
    end
    index
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
    
    respond_to do |format|
      format.js {render 'ordering.js.erb'}
    end
    
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
    
    respond_to do |format|
      format.js {render 'ordered.js.erb'}
    end
    
  end
  
  def recommed_list
    sql = %Q| select id,picture,name,isbn,press,author,recommender,point,intro
                    from books
                    where status = "推荐"
                    order by point DESC
            |
    @recommed = Book.paginate_by_sql(sql,page: params[:page], per_page:10)
    respond_to do |format|
      format.js { render 'reclist.js.erb' }
    end
    
  end
  
  def recbook
    respond_to do |format|
      format.html {render '_recbook.html.erb'}
      format.js
    end
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
      if book.save
        flash.now[:success] = "推荐成功! O(∩_∩)O"
      else
        flash.now[:error] = "推荐失败! (⊙o⊙)"
      end
    end
    recommed_list 
  end
  
  def vote
    book = Book.find_by(id: params[:book_id])
    record = Vote.find_by(user_id: current_user.id)
    
    if record
      # 有投票记录
      if record.book_ids.split(",").include?("#{book.id}")
        flash.now[:info] = "你已为本书投过票,(ˇˍˇ)"
      else
        record.update_attribute(:book_ids, "#{record.book_ids},#{book.id}")
        book.update_attribute(:point, book.point+1)
        flash.now[:success] = "你已投出神圣且重要的一票! O(∩_∩)O"
      end
    else
      # 没有投票记录
      vote = Vote.new
      vote.user_id = current_user.id
      vote.book_ids = book.id
      if vote.save
        book.update_attribute(:point, book.point+1)
        flash.now[:success] = "你已投出神圣且重要的一票! O(∩_∩)O"
      else
        flash.now[:error] = "投票失败!(⊙o⊙)…"
      end
    end
    recommed_list
  end

  def new
    respond_to do |format|
      format.js
    end
  end

  def create
    book = nil
    if book = Book.find_by(isbn: params[:book][:isbn])
      book.store = book.store + params[:book][:total]
      book.total = book.total + params[:book][:total]
    else
      book = Book.new()
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
      book.total = params[:book][:total]
      book.store = book.total
      book.point = 0
    end
    book.status = "已买"
    if book.save
        redirect_to books_index_path, success: '入库成功 O(∩_∩)O'
    else    
         flash[:error] = '入库失败! (⊙o⊙)'
    end
    #index
  end
  
end
