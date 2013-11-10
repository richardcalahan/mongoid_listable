module Mongoid
  module Listable
    
    module Callbacks
      extend ActiveSupport::Concern

      module ClassMethods

        # Defines a mongoid before_create callback.
        # Sets the position field to current object count + 1
        #
        # @param [ Hash ] The configuration hash
        #
        # @return [ Object ] self
        #
        # @since 0.1.0
        def created name
          callback = "#{name}_#{__method__}"
          define_method callback do
            siblings = siblings name
            if self[name].nil?
              set name, siblings.count + 1
            else
              reposition siblings.gte(name => self[name]), name, self[name] + 1
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
        # @param [ Hash ] The configuration hash
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
        # @param [ Hash ] The configuration hash
        #
        # @return [ Object ] self
        #
        # @since 0.1.0
        def destroyed name
          callback = "#{name}_#{__method__}"
          define_method callback do
            reposition siblings(name).gt(name => self[name]), name, self[name]
          end
          before_destroy callback
          self
        end

        # Defines a mongoid has_many relation after_add callback.
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
            if object[field_name(meta)].nil?
              object.set field_name(meta), has_many_count(name) + 1
            end
          end
          meta[:before_add] = callback
          self
        end

        # Defines a mongoid has_many relation before_remove callback.
        # Resets the position index on all objects that came after
        #
        # @param [ Symbol ]   name The name of the has_many relation
        # @param [ MetaData ] meta The MetaData class
        #
        # @return [ Object ] self
        #
        # @since 0.0.6
        def removed name, meta       
          field_name = field_name meta
          callback   = "#{name.to_s.singularize}_removed"
          define_method callback do |object|
            position = object.send field_name
            reposition object.siblings(field_name).gt(field_name => position), 
            field_name, position
            object.unset field_name
          end

          meta[:before_remove] = callback
          self
        end

      end

    end    
  end
end
