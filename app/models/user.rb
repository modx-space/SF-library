# encoding: utf-8
class User < ActiveRecord::Base
  extend Enumerize

  enumerize :building, in: [:PVG01, :PVG02, :PVG03, :PVG05, :PVG06], default: :PVG03
  enumerize :role, in: [:reader, :admin, :super_admin], default: :reader, predicates: true, scope: true

  has_many :borrows
  has_many :books, through: :borrows
  has_many :orders
  has_many :books, through: :orders
  
  before_create :create_token
  before_save { self.email = email.downcase }
  
  has_secure_password

  
  validates :email, presence: true
  validates :name, presence: true
  validates :role, presence: true
  # validates :pwd, length:{ minimum: 6}

  def overdue_books
    self.borrows.where("should_return_date < ?", Time.now)
  end
  
  def User.new_remember_token
	SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
	Digest::SHA1.hexdigest(token.to_s)
  end

  def self.search(search, page)
    if search != nil
      where('name like ? or team like ? or building = ?',
         "%#{search}%","%#{search}%","%#{search}%").paginate(page: page, per_page: BOOK_PER_PAGE)
    else
      paginate(page: page, per_page: BOOK_PER_PAGE)
    end
  end

  private
  	def create_token
  		self.remember_token = User.encrypt(User.new_remember_token)
  	end
  end
