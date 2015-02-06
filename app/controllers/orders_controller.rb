class OrdersController < ApplicationController

  before_action :signed_in_user, :profile_complete?
  load_and_authorize_resource

  def create
    order = Order.new
    order.user_id = current_user.id
    order.book_id = params[:book_id]
    order.status = :in_queue

    if order.save
      book = Book.find(params[:book_id])
      record_count = book.order_queue_count
      flash[:success] = "预订成功! 排队序号为: #{record_count} "
    else
      # 预订失败
      logger.error order.errors
      flash[:error] = "预订失败:" << order.errors.full_messages.join('; ')
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
