class Numeric
   def ordinal
     cardinal = self.to_i.abs
     if (10...20).include?(cardinal) then
       cardinal.to_s << 'th'
     else
       cardinal.to_s << %w{th st nd rd th th th th th th}[cardinal % 10]
     end
   end
end

class EntriesController < ApplicationController
  before_filter :login_required
  
  def index; end
  def reports
    @offset = (params[:offset] || 0).to_i
    date = (Time.now - (@offset * 24).hours)
    day = date.strftime('%d').to_i.ordinal
    @day = date.strftime("%A the #{day}")
    @tags = current_user.entries.day(@offset).calculate_tags
  end
  
  def create
    params[:entry][:user_openid] = current_user.openid
    entry = Entry.create_or_update(params[:entry])
    render :text => entry.short_time
  end
end
