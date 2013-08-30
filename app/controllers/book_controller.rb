class BookController < ApplicationController
  
  before_action :signed_in_user, only: [:index]
  
  def index
    books = Book.all
    @books_new = books[0..5]
    @books_hot = books[5...8]
    @books_rec = books[9..11]
    render 'book_home'
  end
  
  def show
    @books = Book.paginate(page: params[:page], per_page:10)
    @page = params[:page]
    render 'index'
  end
  
  def create
    @hi = "Hi"
  end
end
