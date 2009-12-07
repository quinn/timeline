class Entry
  include DataMapper::Resource
  
  property :started_at, DateTime, :key => true
end
