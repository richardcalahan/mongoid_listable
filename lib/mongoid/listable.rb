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

    # Counts unique children of object
    # Needed because the "added" callback doesnt remove
    # duplicate has_many relations until after invoked.
    #
    # @since 0.0.7
    def has_many_count name
      send(name).uniq(&:id).count
    end

  end
end
