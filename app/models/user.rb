# encoding: utf-8
class User < ActiveRecord::Base
  extend Enumerize

  enumerize :building, in: [:PVG01, :PVG02, :PVG03, :PVG05, :PVG06], default: :PVG03
  enumerize :role, in: [:reader, :admin, :super_admin], default: :reader, predicates: true, scope: true
  enumerize :status, in: [:active, :inactive], scope: true, default: :active, predicates: true

  has_many :borrows
  has_many :books, through: :borrows
  has_many :orders
  has_many :books, through: :orders
  
  before_create :create_token
  before_validation :default_password
  before_save { self.email = email.downcase }
  
  has_secure_password

  SUPER_ADMIN_PASSWD = 'super246'
  ADMIN_PASSWD = 'admin987'
  DEFAULT_PASSWD = '123456'

  scope :on_board, -> { with_status(:active)  }
  
  validates :email, :name, :status, presence: true
  validates :email, :sf_email, uniqueness: { case_sensitive: false }
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
      where('name like ? or team like ? or building = ? or email like ? or office = ? or sf_email like ?',
         "%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%","%#{search}%").paginate(page: page, per_page: BOOK_PER_PAGE)
    else
      paginate(page: page, per_page: BOOK_PER_PAGE)
    end
  end

  def display_name
    index = self.name.index(/[^A-Za-z]/)
    index.nil? ? self.name.capitalize : 
      self.name[0, index].capitalize
  end

  def display_location
    seat_part = ('.' + self.seat.to_s) if !self.seat.nil?
    self.building.to_s + ' ' + self.office.to_s + seat_part.to_s
  end

  def has_admin_authe
    self.admin? || self.super_admin?
  end

  private
  	def create_token
  		self.remember_token = User.encrypt(User.new_remember_token)
  	end

    def default_password
      if self.password.nil? || self.password_confirmation.nil?    
        if self.super_admin?
          self.password = User::SUPER_ADMIN_PASSWD
          self.password_confirmation = User::SUPER_ADMIN_PASSWD
        elsif self.admin?
          self.password = User::ADMIN_PASSWD
          self.password_confirmation = User::ADMIN_PASSWD
        else
          self.password = User::DEFAULT_PASSWD
          self.password_confirmation = User::DEFAULT_PASSWD
        end
      end
    end
  end
