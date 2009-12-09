class EntriesController < ApplicationController
  before_filter :login_required
  
  def index; end
  def reports; end
  
  def create
    params[:entry][:user_openid] = current_user.openid
    entry = Entry.create_or_update(params[:entry])
    render :text => entry.short_time
  end
end
