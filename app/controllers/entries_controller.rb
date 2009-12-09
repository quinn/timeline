class EntriesController < ApplicationController
  def index
  end
  
  def create
    params[:entry][:user_openid] = current_user.openid
    entry = Entry.create_or_update(params[:entry])
    render :text => entry.short_time
  end
  
  def reports
    
  end
end
