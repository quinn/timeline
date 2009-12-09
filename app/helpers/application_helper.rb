# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def current_user
    User.get(session[:current_user_openid])
  end
  
  def current_user= user
    session[:current_user_openid] = user.openid
  end
  
  def signed_in?
    !!session[:current_user_openid]
  end
end
