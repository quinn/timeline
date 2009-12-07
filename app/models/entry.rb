class Entry
  include DataMapper::Resource
  
  property :started_at, DateTime, :key => true
  property :ended_at, DateTime, :nullable => true
  property :color, String, :length => 7

  belongs_to :parent_entry, :model => 'Entry', :child_key => [ :ended_at ]
  
  def short_time
    started_at.strftime('%l:%M') + started_at.strftime(' %p').downcase
  end
  
  def raw_time= milliseconds
    self.started_at = Time.at(milliseconds.to_i / 1000.0)
  end
  
  def parent= milliseconds
    self.parent_entry = Entry.get! Time.at(milliseconds.to_i / 1000.0)
  end
  
  def self.beginning_of_day
    all :started_at.gte => Time.now.beginning_of_day
  end

  def self.end_of_day
    all :started_at.lte => Time.now.end_of_day
  end
  
  def self.today
    beginning_of_day.end_of_day.all :order => [:started_at.asc]
  end
end
