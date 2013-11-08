require 'mongoid/listable/accessors'
require 'mongoid/listable/macros'

module Mongoid
  module Listable
    extend ActiveSupport::Concern

    included do 
      include Mongoid::Listable::Accessors
      include Mongoid::Listable::Macros
    end
  end
end
