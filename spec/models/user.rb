class User

  include Mongoid::Document
  include Mongoid::Listable

  field :first_name, type: String, default: 'Richard'
  field :last_name, type: String, default: 'Calahan'

  has_many :photos
  
  lists :photos

end
