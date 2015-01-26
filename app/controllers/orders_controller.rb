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
      order_record = Order.find_by(user_id: current_user.id, book_id: params[:book_id], status: :in_queue)
      if order_record
        flash[:error] = "你已预约此书，请耐心等候..."
      else
        order = Order.new
        order.user_id = current_user.id
        order.book_id = params[:book_id]
        order.status = :in_queue
        record_count = book.previous_order_count
        if order.save
          flash[:success] = "预订成功! 排队序号为: #{record_count+1} "
        else
          # 预订失败
          logger.error order.errors
          flash[:error] = "预订失败: " << order.errors.full_messages.to_s
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
      flash[:error] = "订单取消失败: " << @order.errors.full_messages.to_s
    end
    respond_to do |format|
      format.html {redirect_to(:back) }
    end
  end

  def current_list
    page = params[:page] || 1
    @orders = Order.where("user_id = :user_id and orders.status = :status", 
                      {user_id: current_user.id, status: :in_queue})
                      .search(params[:tag])
                      .sort(params[:sort], Order.current_sort_types)
                      .paginate(page: page, per_page: BOOK_PER_PAGE)
    render_list_page('current_index.html.erb')
  end

  def history_list
    page = params[:page] || 1
    @orders = Order.where("user_id = :user_id and orders.status != :status", 
                      {user_id: current_user.id, status: :in_queue})
                      .search(params[:tag])
                      .sort(params[:sort], Order.history_sort_types)
                      .paginate(page: page, per_page: BOOK_PER_PAGE)

    render_list_page('history_index.html.erb')
  end

  def admin_current
    page = params[:page] || 1
    @orders = Order.where("orders.status = :status", 
                      {status: :in_queue})
                      .admin_search(params[:tag])
                      .sort(params[:sort], Order.current_sort_types)
                      .paginate(page: page, per_page: BOOK_PER_PAGE)
    render_list_page('current_index.html.erb')
  end

  def admin_history
    page = params[:page] || 1
    @orders = Order.where("orders.status != :status", 
                      {status: :in_queue})
                      .admin_search(params[:tag])
                      .sort(params[:sort], Order.history_sort_types)
                      .paginate(page: page, per_page: BOOK_PER_PAGE)

    render_list_page('history_index.html.erb')
  end

  private 

  def render_list_page (path)
    respond_to do |format|  
      format.html {render path} 
    end
  end

end
