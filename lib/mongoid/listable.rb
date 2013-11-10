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
    # @param [ MetaData ] meta The MetaData class
    # @see Class.field_name
    #
    # @since 0.0.6
    def field_name meta
      self.class.field_name meta
    end

    # Counts unique children of object
    # Needed because the mongoid callbacks dont update
    # has_many relations until after invoked.
    #
    # @param [ Symbol ]   name The name of the has_many relation
    #
    # @since 0.0.7
    def has_many_count name
      send(name).uniq(&:id).count
    end

    # Retrieves an object's list siblings
    #
    # @return [ Array ]
    #
    # @since 0.1.0
    def siblings field=:position
      self.class.exists(field => true).ne id: id
    end

    private

    # Resets column on objects starting at 'start'
    #
    # @param [ Array ] objects The objects to interate
    # @param [ Symbol ] column The column to update
    # @param [ Integer ] start The starting position
    #
    # @since 0.1.0
    def reposition objects, column, start
      objects.each_with_index do |object, index|
        object.set column, start + index
      end
    end

  end
end
