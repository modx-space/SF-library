# encoding: utf-8
class Order < ActiveRecord::Base
  extend Enumerize

  enumerize :status, in: [:in_queue, :handled, :canceled], scope: true

  belongs_to :user
  belongs_to :book
  
  def shipout_order
    self.status = :handled
    self.save!
  end

  def cancel
    self.status = :canceled
    self.save
  end
end
