require 'mongoid/listable/macros'

module Mongoid
  module Listable

    extend ActiveSupport::Concern

    included do 
      extend Mongoid::Listable::Macros
    end

  end
end
