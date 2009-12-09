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
  property :tags, Text
  
  has 1, :previous_entry, :model => 'Entry', :child_key => [ :ended_at ]
  belongs_to :next_entry, :model => 'Entry', :child_key => [ :ended_at ]
  belongs_to :user
  
  def self.create_or_update params
    new_entry = new params
    begin
      return new_entry if new_entry.save
    rescue DataObjects::IntegrityError
      entry = Entry.get! new_entry.started_at
      attrs = new_entry.attributes
      attrs.each{|k,v| 
        attrs.delete(k) if v.blank?
      }
      return entry if entry.update(attrs)
    end
  end
  
  def short_time
    started_at.strftime('%l:%M') + started_at.strftime(' %p').downcase
  end
  
  def full_time
    started_at.strftime('%l:%M') + started_at.strftime(' %p').downcase +
    " - "+ ended_at.strftime('%l:%M') + ended_at.strftime(' %p').downcase
  rescue
    short_time
  end
  
  def raw_time= milliseconds
    self.started_at = Time.at(milliseconds.to_i / 1000.0)
  end
  
  def raw_ending= milliseconds
    self.ended_at = Time.at(milliseconds.to_i / 1000.0)
  end
  
  def parent= milliseconds
    self.previous_entry = Entry.get!( Time.at(milliseconds.to_i / 1000.0) )
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
    if ended_at
      dom.merge! :'data-ended_at' => ended_at.milliseconds 
      dom[:style] += "; width: #{width}%"
    end
    dom
  end
  
  def width
    ((ended_at.milliseconds - started_at.milliseconds) / (1.hour * 1000.0)) * 100
  end
  
  def length
    ending = ended_at ? ended_at : Time.now
    ending.to_f - started_at.to_f
  end
  
  # big for now. will make real l8r
  def self.todays_tags
    tags = {}
    returning = []
    between(Time.now.beginning_of_day, Time.now.end_of_day).each do |entry|
      entry.tags.split(",").map{|t| t.strip}.each do |tag|
        tags[tag] ||= []
        tags[tag] << entry
      end
    end
    
    tags.each do |tag, entries|
      total_time = 0.0
      
      # catch(:ongoing) do      
        entries.each do |entry|
          total_time += entry.length
          # if entry.ended_at.nil?
          #   total_time = "ongoing"
          #   throw(:ongoing)
          # end
        end
        seconds = ((total_time % 3600) / 60).round
        seconds = (seconds.to_s.length == 1) ? "0#{seconds}" : seconds
        total_time = "#{(total_time / 3600).floor}:#{seconds}"
      # end
      
      returning << {
        :tag => tag,
        :entries => entries,
        :total_time => total_time
      }
    end
    
    returning
  end
end
