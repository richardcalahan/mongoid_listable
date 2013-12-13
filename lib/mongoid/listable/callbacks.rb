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
          register_callback name, :before_create do
            if position = send(name)
              objects = siblings(name).gte(name => position)
              reposition objects, name, position + 1
            else
              set name, siblings(name).count + 1
            end
          end
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
          register_callback name, :before_update do
            apply_change_on name if send("#{name}_changed?")
          end
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
          register_callback name, :before_destroy do
            siblings = siblings(name).gt(name => send(name))
            reposition siblings, name, send(name)
          end
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
          register_callback name, :after_add do |object|
            return unless object.new_record?
            field_name = position_field_name meta
            if position = object.send(field_name) 
              objects = object.siblings(field_name).gte(field_name => position)
              reposition objects, field_name, position + 1
            else                       
              object.set field_name, many(name).count
            end
          end
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
          register_callback name, :before_remove do |object|
            field_name = position_field_name meta
            objects    = object.siblings(field_name)
              .gt(field_name => object.send(field_name))
            reposition objects, field_name, object.send(field_name)
            object.unset field_name            
          end
        end

        private
        
        # Registers a callback using name (either the position 
        # field, or in the case of a has_many/embeds_many relationship, 
        # the relation name) as a unique identifier for the generated 
        # method name.
        #
        # If reflect_on_association(name) returns non-nil, we know 
        # this is a has_many/embeds_many relationship, and we register 
        # the callback on the inverse class of the relation. If the 
        # return value is nil, register the callback on the class itself.
        #
        # @param [ Symbol ]        name  The name of the position field
        # @param [ Symbol|String ] hook  The name of the Mongoid relation callback
        # @param [ Proc ]          block The body of the callback method
        #
        # @return [ Object ] self
        #
        # @since 0.0.6
        def register_callback name, hook, &block
          meta     = reflect_on_association name
          callback = "#{hook}_#{name}" 

          define_method callback, &block

          meta ? meta[hook] = callback : send(hook, callback) 
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
        if to > from
          reposition siblings(name).between(name => from..to), name, from
        elsif to < from       
          reposition siblings(name).between(name => to..from), name, to + 1
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
        from ||= siblings(name).count
        to ||= siblings(name).count + 1
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
