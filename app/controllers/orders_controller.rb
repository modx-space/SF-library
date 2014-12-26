class OrdersController < ApplicationController

  before_action :signed_in_user
  load_and_authorize_resource

  def create
    book = Book.find(params[:book_id])
    borrow_record = Borrow.find_by(user_id: current_user.id, book_id: params[:book_id], status: :borrowing)
    if borrow_record
      # 已在使用，无需预订
      flash[:info] = "你已在使用本书，不可预订..."
    else
      order_record = Order.find_by(user_id: current_user.id, book_id: params[:book_id], status: ORDER_STATUSES.index('排队中'))
      if order_record
        flash[:error] = "你已预约此书，请耐心等候..."
      else
        order = Order.new
        order.user_id = current_user.id
        order.book_id = params[:book_id]
        order.status = ORDER_STATUSES.index('排队中')
        record_count = book.order_queue_count
        if order.save
          flash[:success] = "预订成功! 排队序号为: #{record_count+1} "
        else
          # 预订失败
          logger.error order.errors
          flash[:error] = "预订失败!"
        end
      end
    end
    respond_to do |format|
       format.html { redirect_to :back } 
    end
  end

  def cancel
    @order = Order.find(params[:id])
    if @order.cancel
      flash[:success] = "订单取消成功"
    else
      flash[:error] = "订单取消失败!"
    end
    respond_to do |format|
      format.html {redirect_to(:back) }
    end
  end

  def current_list
    page = params[:page] || 1
    @orders = Order.where("user_id = :user_id and status = ':status'", 
                      {user_id: current_user.id, status: ORDER_STATUSES.index('排队中')})
                      .paginate(page: page, per_page: BOOK_PER_PAGE)
    render_list_page('current_index.html.erb', @orders.size)
  end

  def history_list
    page = params[:page] || 1
    @orders = Order.where("user_id = :user_id and status = ':status'", 
                      {user_id: current_user.id, status: ORDER_STATUSES.index('已处理')})
                      .paginate(page: page, per_page: BOOK_PER_PAGE)

    render_list_page('history_index.html.erb', @orders.size)
  end

  def admin_current
    page = params[:page] || 1
    @orders = Order.where("status = ':status'", 
                      {status: ORDER_STATUSES.index('排队中')})
                      .paginate(page: page, per_page: BOOK_PER_PAGE)
    render_list_page('current_index.html.erb', @orders.size)
  end

  def admin_history
    page = params[:page] || 1
    @orders = Order.where("status = ':status'", 
                      {status: ORDER_STATUSES.index('已处理')})
                      .paginate(page: page, per_page: BOOK_PER_PAGE)

    render_list_page('history_index.html.erb', @orders.size)
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
