class Entry
  include DataMapper::Resource
  
  property :started_at, DateTime, :key => true
  
  
  def short_time
    started_at.strftime('%l:%M') + started_at.strftime(' %p').downcase
  end
end
