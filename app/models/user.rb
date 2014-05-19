# encoding: utf-8
class User < ActiveRecord::Base
  
  has_many :borrows
  has_many :books, through: :borrows
  has_many :orders
  has_many :books, through: :orders
  
  before_create :create_token
  before_save { self.email = email.downcase }
  
  has_secure_password

  
  validates :email, presence: true
  validates :name, presence: true
  validates :cate, presence: true
  # validates :pwd, length:{ minimum: 6}

  DEFAULT_PASSWORD = '123456'
  self.per_page = 10
  
	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	def self.search_by_tag(search, page)
            paginate :per_page => 10, :page => page,   
                       :conditions => ['name like ?', "%#{search}%"]
	end
  
	def self.search(page)
	  paginate :per_page => 10, :page => page
	end
	
	
	private
		def create_token
			self.remember_token = User.encrypt(User.new_remember_token)
		end
end
