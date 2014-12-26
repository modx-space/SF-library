# encoding: utf-8
require "open-uri"
require "json"
class BooksController < ApplicationController
  
  before_action :signed_in_user
  load_and_authorize_resource
  
  #new_hot
  def library
    books = Book.all
    @books_new = Book.order("created_at DESC")[0..5]
    
    sql = %Q| select * from borrows
                group by book_id
                order by count(1)
            |
    @books_hot = Borrow.find_by_sql(sql)[0..2]
    
    sql = %Q| select id,picture,name,isbn,press,author,point
                    from books
                    order by created_at DESC
            |
    @books_rec = Book.find_by_sql(sql)[0..2]
    
  end
  
  def index
    page = params[:page] || 1
    sql = %Q| select * from books where status = "已买" |
    if params[:tag] != nil
      @books = Book.search_by_tag(params[:tag], page)
    else
      @books = Book.search(page)
    end

    respond_to do |format|
      format.html
    end
    
  end

  def admin_index
    page = params[:page] || 1
    sql = %Q| select * from books where status = "已买" |
    if params[:tag] != nil
      @books = Book.search_by_tag(params[:tag], page)
    else
      @books = Book.search(page)
    end
    respond_to do |format|
      format.html { render 'index.html.erb'}
    end

  end
  
  def edit
    @book = Book.find(params[:id])
  end

  def show
    @book = Book.find(params[:id])
    @order_number = @book.order_queue_count
    @borrow_conditions = @book.borrow_conditions
    @order_conditions = @book.order_conditions
  end
  
  def recommed_list
    sql = %Q| select id,picture,name,isbn,press,author,recommender,point,intro
                    from books
                    where status = '#{Book::REC}'
                    order by point DESC
            |
    @recommed = Book.paginate_by_sql(sql,page: params[:page], per_page: BOOK_PER_PAGE)
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
          @book[:category] = response["tags"][0]["name"]
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
      book.category = params[:book][:category]
      book.price = params[:book][:price]
      book.total = 0
      book.store = 0
      book.point = 0
      book.status = Book::REC
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
      format.html
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
      book.category = params[:book][:category]
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
