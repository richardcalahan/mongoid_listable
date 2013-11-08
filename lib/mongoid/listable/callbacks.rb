module Mongoid
  module Listable
    
    module Callbacks
      extend ActiveSupport::Concern

      module ClassMethods

        # Defines a mongoid relation after_add callback.
        # Sets the position attribute to current relations length + 1      
        def added name, meta
          callback = "#{name.to_s.singularize}_added"
          define_method callback do |object|
            objects = send(name).uniq &:id
            object.update_attribute field_name(meta), 
            (objects.index(object) || objects.count) + 1
          end
          meta[:after_add] = callback
          self
        end

        # Defines a mongoid relation before_remove callback.
        # Resets the position index on all objects that came after
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
