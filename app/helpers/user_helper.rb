# encoding: utf-8
module UserHelper
    
    def say_hello
      now_hour = Time.new.hour
      @hello = "你好"
      case now_hour
        when (0...12) then @hello = "上午好"
        when (12...20) then @hello = "下午好"
        else @hello = "晚上好"
      end
    end
     
    def sign_in(user)
  		remember_token = User.new_remember_token
    	cookies.permanent[:remember_token] = remember_token
      cookies[:remember_token]= { value: remember_token, expires: 1.hour.from_now }
    	user.update_attribute(:remember_token, User.encrypt(remember_token))
      self.current_user = user
    end

    def current_user=(user)
      @current_user = user
    end

    def current_user
    	remember_token = User.encrypt(cookies[:remember_token])
    	@current_user ||= User.find_by(remember_token:remember_token)
    end

    def signed_in?
      !current_user.nil?
    end

    def signed_in_user
      unless signed_in?
        redirect_to root_path, notice: "请先登录."
      end
    end

    def profile_complete?
      if current_user.profile_not_complete?
        redirect_to root_path, alert: "请先完善您的座位信息以及i_number :)"
      end
    end

    def sign_out
        self.current_user = nil
        cookies.delete(:remember_token)
    end

end
