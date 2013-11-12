module Mongoid
  module Listable
    
    module Callbacks
      extend ActiveSupport::Concern

      module ClassMethods

        # Defines a mongoid before_create callback.
        # Sets the position field to current object count + 1
        #
        # @param [ Symbol ] The name of the position field
        #
        # @return [ Object ] self
        #
        # @since 0.1.0
        def created name
          callback = "#{name}_#{__method__}"
          define_method callback do
            if position = send(name)
              objects = siblings(name).gte(name => position)
              reposition objects, name, position + 1
            else
              set name, siblings(name).count + 1
            end
          end

          before_create callback
          self
        end

        # Defines a mongoid before_update callback.        
        # If the position column has changed, apply the change.
        # Hoe the change is applied varies depending on the redrection
        # of the update.
        #
        # @param [ Symbol ] The name of the position field
        #
        # @return [ Object ] self
        #
        # @since 0.1.0
        def updated name
          callback = "#{name}_#{__method__}"
          define_method callback do       
            apply_change_on name if send("#{name}_changed?")
          end
          before_update callback
          self
        end

        # Defines a mongoid before_destroy callback.        
        # Resets all sibling object's higher in the list
        #
        # @param [ Symbol ] The name of the position field
        #
        # @return [ Object ] self
        #
        # @since 0.1.0
        def destroyed name
          callback = "#{name}_#{__method__}"
          define_method callback do
            siblings = siblings(name).gt(name => send(name))
            reposition siblings, name, send(name)
          end

          before_destroy callback
          self
        end

        # Defines a mongoid 1-n relation after_add callback.
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
            return unless object.new_record?
            field_name = position_field_name meta
            if position = object.send(field_name) 
              objects = object.siblings(field_name).gte(field_name => position)
              reposition objects, field_name, position + 1
            else                       
              object.set field_name, many(name).count
            end
          end
          meta[:after_add] = callback
          self
        end

        # Defines a mongoid 1-n relation before_remove callback.
        # Resets the position index on all objects that came after
        #
        # @param [ Symbol ]   name The name of the has_many relation
        # @param [ MetaData ] meta The MetaData class
        #
        # @return [ Object ] self
        #
        # @since 0.0.6
        def removed name, meta       
          callback   = "#{name.to_s.singularize}_removed"
          define_method callback do |object|
            field_name = position_field_name meta
            objects    = object.siblings(field_name)
            .gt(field_name => object.send(field_name))
            reposition objects, field_name, object.send(field_name)
            object.unset field_name
          end

          meta[:after_remove] = callback
          self
        end

      end # ClassMethods

      private

      # Applies a position change on field. Which objects are repositioned
      # depends on the direction of the change.
      #
      # @param [ Symbol ] name The name of position field
      #
      # @since 0.1.0
      def apply_change_on name
        from, to = change_on name
        siblings = siblings name
        if to > from
          reposition siblings.between(name => from..to), name, from
        elsif to < from       
          reposition siblings.between(name => to..from), name, to + 1
        end
        set name, to
      end

      # Returns the old and new values for column
      #
      # @param [ Symbol ] column The column to retrieve the change
      # @return [Array] [from, to]
      #
      # @since 0.1.0
      def change_on name
        from, to = send "#{name}_change"
        from ||= 0
        to = if to > siblings(name).count + 1
               siblings(name).count + 1
             elsif to < 1
               1
             else
               to
             end
        [from, to]
      end

    end    
  end
end
