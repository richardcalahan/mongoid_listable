class Item

  include Mongoid::Document
  include Mongoid::Listable

  listed field: :custom_field, scope: :custom_scope

end
