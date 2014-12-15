# encoding: utf-8
class Order < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :book
  
  def shipout_order
    self.status = ORDER_STATUSES.index('已处理')
    self.save!
  end
end
