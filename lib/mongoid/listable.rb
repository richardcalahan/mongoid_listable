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

    private

    # Applies a position change on column. Which objects are repositioned
    # depends on the direction of the change.
    #
    # @param [ Symbol ] name The name of position column
    #
    # @since 0.1.0
    def apply_change_on column
      from, to = change_on column
      if to > from
        reposition siblings.between(column => from..to), column, from
      elsif to < from       
        reposition siblings.between(column => to..from), column, to + 1
      end
      set column, to
    end

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

    # Returns the old and new values for column
    #
    # @param [ Symbol ] column The column to retrieve the change
    # @return [Array] [from, to]
    #
    # @since 0.1.0
    def change_on column
      from, to = send "#{column}_change"
      to = safe_to to
      [from, to]
    end

    # Ensures the 'to' value is within acceptable bounds
    #
    # @param [ Integer ] to The supplied position value
    # @return [ Integer ] The acceptable position value
    #
    # @since 0.1.0
    def safe_to to
      if to > self.class.count
        self.class.count
      elsif to < 1
        1
      else
        to
      end
    end

    # Retrieves an object's list siblings
    #
    # @return [ Array ]
    #
    # @since 0.1.0
    def siblings
      self.class.list.ne id: id
    end

  end
end
