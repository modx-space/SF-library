# encoding: utf-8

class DefaultController < ApplicationController
  
  def home
    @books_new = Book.new_book_list
  end
  
end
