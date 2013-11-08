module Mongoid
  module Listable
    
    module Callbacks
      extend ActiveSupport::Concern

      module ClassMethods

        # Defines a mongoid relation after_add callback.
        # Sets the position attribute to current relations length + 1
        #
        # @param [ Symbol ]   name The name of the has_many relation
        # @param [ MetaData ] meta The MetaData class
        #
        # @return [ Object ] self
        #
        # @since 0.0.6
        def added name, meta
          callback = "#{name.to_s.singularize}_added"
          define_method callback do |object|
            count = send(name).uniq(&:id).count
            object.update_attribute field_name(meta), count
          end
          meta[:after_add] = callback
          self
        end

        # Defines a mongoid relation before_remove callback.
        # Resets the position index on all objects that came after
        #
        # @param [ Symbol ]   name The name of the has_many relation
        # @param [ MetaData ] meta The MetaData class
        #
        # @return [ Object ] self
        #
        # @since 0.0.6
        def removed name, meta
          callback = "#{name.to_s.singularize}_removed"
          define_method callback do |object|
            position = object.send field_name(meta)
            send(name).where(field_name(meta).gt => position)
              .each_with_index do |object, index|
              object.update_attribute field_name(meta), position + index
            end
          end
          meta[:before_remove] = callback
          self
        end

      end

    end
    
  end
end
