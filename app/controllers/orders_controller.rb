class OrdersController < ApplicationController

  before_action :signed_in_user
  load_and_authorize_resource

  def create
    book = Book.find(params[:book_id])
    borrow_record = Borrow.find_by(user_id: current_user.id, book_id: params[:book_id], status: BORROW_STATUSES.index('借阅中'))
    if borrow_record
      # 已在使用，无需预订
      flash[:info] = "你已在使用本书，不必预订..."
    else
      order_record = Order.find_by(user_id: current_user.id, book_id: params[:book_id], status: ORDER_STATUSES.index('排队中'))
      if order_record
        flash[:error] = "你已预定此书，请耐心等候..."
      else
        order = Order.new
        order.user_id = current_user.id
        order.book_id = params[:book_id]
        order.status = ORDER_STATUSES.index('排队中')
        record_count = Order.count(conditions: "status = '#{ORDER_STATUSES.index('排队中')}'")
        if order.save
          book.update_attribute(:store, book.store-1)
          flash[:success] = "预订成功! 你的服务序号为: #{record_count+1} "
        else
          # 预订失败
          flash[:error] = "预订失败!"
        end
      end
    end
    respond_to do |format|
       format.html { redirect_to edit_book_path(book.id) } 
    end
  end

  def order_current
    page = params[:page] || 1
    @orders = Order.where("user_id = :user_id and status = ':status'", 
                      {user_id: current_user.id, status: ORDER_STATUSES.index('排队中')})
                      .paginate(page: page, per_page: BOOK_PER_PAGE)
    respond_to do |format|
      format.html {render 'index.html.erb'}
    end
  end

  def order_history
    page = params[:page] || 1
    @orders = Order.where("user_id = :user_id and status = ':status'", 
                      {user_id: current_user.id, status: ORDER_STATUSES.index('已处理')})
                      .paginate(page: page, per_page: BOOK_PER_PAGE)

    respond_to do |format|
      format.html {render 'index.html.erb'}
    end
  end

end
