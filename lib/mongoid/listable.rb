require 'mongoid/listable/accessors'
require 'mongoid/listable/callbacks'
require 'mongoid/listable/extensions'
require 'mongoid/listable/macros'

module Mongoid
  module Listable
    extend ActiveSupport::Concern

    included do
      include Mongoid::Listable::Accessors
      include Mongoid::Listable::Callbacks
      include Mongoid::Listable::Macros
    end

    module ClassMethods

      # Generates the position field name using the MetaData class
      #
      # @param [ MetaData ] meta The MetaData class
      #
      # @return Symbol
      #
      # @since 0.0.6
      def field_name meta
        (meta.foreign_key.to_s.gsub(/_?id$/, '_position')).to_sym
      end

    end

    # Proxies to the class level version
    #
    # @see Class.field_name
    #
    # @since 0.0.6
    def field_name meta
      self.class.field_name meta
    end

  end
end
