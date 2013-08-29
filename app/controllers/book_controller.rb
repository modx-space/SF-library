class BookController < ApplicationController
  
  before_action :signed_in_user, only: [:index]
  
  def index
    render 'book_home'
  end
  
  def create
    @hi = "Hi"
  end
end
