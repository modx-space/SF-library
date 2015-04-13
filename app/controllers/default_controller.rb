# encoding: utf-8

class DefaultController < ApplicationController
  
  def home
    @books_new = Book.new_book_list
    @admins = User.on_board.with_role(:super_admin, :admin)
  end
  
end
