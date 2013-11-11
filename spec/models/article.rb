class Article

  include Mongoid::Document
  include Mongoid::Listable

  embeds_many :sections

  lists :sections

end
