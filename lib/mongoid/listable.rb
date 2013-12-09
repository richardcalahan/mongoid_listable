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

    # Proxies to the class level determine_position_field_name
    #
    # @param [ MetaData ] meta The MetaData class
    # @see Class.field_name
    #
    # @since 0.0.6
    def position_field_name meta
      self.class.determine_position_field_name meta
    end

    # Finds unique instances of objects for a given relation
    # Needed because the mongoid callbacks dont update
    # has_many relations until after invoked.
    #
    # @param [ Symbol ]   name The name of the has_many relation
    #
    # @since 0.2.1
    def many name
      send(name).uniq(&:id)
    end

    # Retrieves siblings of an object in a list. 
    # Scoped by the position fiels name
    #
    # @return [ Array ]
    #
    # @since 0.1.0
    def siblings field=:position
      klass = if embedded_one?
                _parent.send(metadata.key).class
              elsif embedded_many?
                _parent.send(metadata.key)
              else                
                self.class
              end
      klass.where(field.exists => true).ne id: id
    end

    def embedded_one?
      embedded? && metadata[:relation] == Mongoid::Relations::Embedded::One
    end

    def embedded_many?
      embedded? && metadata[:relation] == Mongoid::Relations::Embedded::Many
    end

    private

    # Resets position field on objects starting at 'start'
    #
    # @param [ Array ] objects The objects to interate
    # @param [ Symbol ] column The field to update
    # @param [ Integer ] start The starting position
    #
    # @since 0.1.0
    def reposition objects, field, start
      objects.each_with_index do |object, index|
        object.set field, start + index
      end
    end

    module ClassMethods

      # Generates the position field name using the MetaData instance
      #
      # @param [ MetaData ] meta The MetaData instance
      #
      # @return Symbol
      #
      # @since 0.2.1
      def determine_position_field_name meta
        (meta.foreign_key.to_s.gsub(/_?id$/, '_position')).to_sym
      end

    end

  end
end
