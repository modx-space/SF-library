class BookController < ApplicationController
  
  before_action :signed_in_user, only: [:index]
  
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
  
end
