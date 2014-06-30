class BorrowsController < ApplicationController

  before_action :signed_in_user

  def create
  	@borrow = current_user.amounts
  end
end
