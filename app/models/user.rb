# encoding: utf-8
class User < ActiveRecord::Base
  DAYS_OVERDUE = 20

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

  scope :admin, where(role: 'admin')

  def is_admin?
    role == nil ? false : role.to_sym == :admin
  end

  def role_name(role)
  	hash = {:admin => '管理员', :reader => '用户'}
  	hash[role.to_sym]
  end

  def overdue_books
    self.borrows.where("updated_at < ?", Time.now - DAYS_OVERDUE.day)
  end
  
  def User.new_remember_token
	SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
	Digest::SHA1.hexdigest(token.to_s)
  end

  def self.search_by_tag(search, page)
        paginate :per_page => USER_PER_PAGE, :page => page,   
                   :conditions => ['name like ?', "%#{search}%"]
  end

  def self.search(page)
    paginate :per_page => USER_PER_PAGE, :page => page
  end


  private
  	def create_token
  		self.remember_token = User.encrypt(User.new_remember_token)
  	end
  end
