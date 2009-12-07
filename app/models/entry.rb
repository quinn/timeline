class DateTime
  def milliseconds
    (to_f * 1000.0).to_i
  end  
end

class Entry
  include DataMapper::Resource
  
  property :started_at, DateTime, :key => true
  property :ended_at, DateTime, :nullable => true
  property :color, String, :length => 18

  has 1, :previous_entry, :model => 'Entry', :child_key => [ :ended_at ]
  belongs_to :next_entry, :model => 'Entry', :child_key => [ :ended_at ]
  
  def self.create_or_update params
    new_entry = new params
    begin
      return new_entry if new_entry.save
    rescue DataObjects::IntegrityError
      entry = Entry.get! new_entry.started_at
      return entry if entry.update(new_entry.attributes)
    end
  end
  
  def short_time
    started_at.strftime('%l:%M') + started_at.strftime(' %p').downcase
  end
  
  def raw_time= milliseconds
    self.started_at = Time.at(milliseconds.to_i / 1000.0)
  end
  
  def raw_ending= milliseconds
    self.ended_at = Time.at(milliseconds.to_i / 1000.0)
  end
  
  def parent= milliseconds
    entry = Entry.get! Time.at(milliseconds.to_i / 1000.0)
    entry.next_entry = self
    entry.save
  end
  
  def self.each_hour
    24.times do |hour|
      start = Time.now.beginning_of_day + hour.hours
      ending = Time.now.beginning_of_day + (hour + 1).hours
      yield between(start, ending).all(:order => [:started_at.asc]), hour
    end
  end
  
  def self.between(start, ending)
    all :started_at.gte => start, :started_at.lte => ending
  end
  
  def to_dom
    dom = {
      :id => started_at.milliseconds, 
      :style => "background-color: #{color}" }
    dom.merge! :'data-ended_at' => ended_at.milliseconds if ended_at
    dom
  end
end
