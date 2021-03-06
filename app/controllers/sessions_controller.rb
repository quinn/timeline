class SessionsController < ApplicationController
  def create
    open_id_authentication
  end
  
  def show
    open_id_authentication
  end
  
  protected
    def open_id_authentication
      authenticate_with_open_id do |result, identity_url|
        if result.successful?
          if self.current_user = User.get(identity_url) || User.create(:openid => identity_url)
            successful_login
          else
            failed_login "Sorry, my hands are made of jello"
          end
        else
          failed_login result.message
        end
      end
    end
  
  
  private
    def successful_login
      redirect_to(root_url)
    end

    def failed_login(message)
      flash[:error] = message
      redirect_to(new_session_url)
    end
end
