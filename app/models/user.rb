class User
  include DataMapper::Resource
  property :openid, String, :length => 150, :key => true
  has n, :entries
end
