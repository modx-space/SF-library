# encoding: utf-8
class Borrow < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :book
  
end
