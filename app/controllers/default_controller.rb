class DefaultController < ApplicationController
  
  def home
    books = Book.all
    @books_new = books[0..5]
  end
  
end
