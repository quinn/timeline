# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  def current_user
    User.get(session[:current_user_openid])
  end
  
  def current_user= user
    session[:current_user_openid] = user.openid
  end
end
