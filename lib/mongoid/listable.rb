require 'mongoid/listable/accessors'
require 'mongoid/listable/macros'

module Mongoid
  module Listable
    include Mongoid::Listable::Accessors
    include Mongoid::Listable::Macros
  end
end
