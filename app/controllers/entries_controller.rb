class EntriesController < ApplicationController
  def create
    entry = Entry.create(params[:entry])
    render :text => entry.short_time
  end
end
