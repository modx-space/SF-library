# encoding: utf-8

class DefaultController < ApplicationController
  
  def home
    books = Book.all
    @books_new = Book.order("created_at DESC")[0..5]
  end
  
end
