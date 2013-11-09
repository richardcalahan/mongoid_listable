class Photo

  include Mongoid::Document
  include Mongoid::Listable

  field :caption, type: String

  belongs_to :user

end
