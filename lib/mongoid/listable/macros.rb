module Mongoid
  module Listable

    # This module contains the core macro for defining listable 
    # has_many relationships
    module Macros
      extend ActiveSupport::Concern

      module ClassMethods

        # Macro to set relation on which to make a list
        #
        # @param [ Symbol ] relation The name of the has_many relation
        # @param [ Hash ]   options The options hash
        #
        # @return [ Mongoid:Relations:Metadata ] Instance of metadata
        #
        # @since 0.0.1
        def lists name, options={}
          singular_name             = name.to_s.singularize
          relation_added_callback   = "#{singular_name}_added"
          relation_removed_callback = "#{singular_name}_removed"
          meta                      = reflect_on_association name
          field_name                = options[:column] || 
            (meta.foreign_key.to_s.gsub(/_?id$/, '_position')).to_sym

          meta.klass.send :field, field_name, type: Integer             

          _ids_setter(name, meta)

          # Prepends to the default setter a block that sets the position
          # attribute on each object according to its index in the array
          #
          # @override model#{name}=
          before_method self, "#{name}=" do |objects|
            objects.each_with_index do |object, index|
              object.update_attribute field_name, index + 1
            end

            (send(name).to_a - objects).each do |object|
              object.unset field_name
            end
          end

          # Defines a mongoid relation after_add callback.
          # Sets the position attribute to current relations length + 1
          define_method relation_added_callback do |object|
            objects = send(name).uniq &:id
            object.update_attribute field_name, 
            (objects.index(object) || objects.count) + 1
          end

          # Defines a mongoid relation before_remove callback.
          # Resets the position index on all objects that came after
          define_method relation_removed_callback do |object|
            position = object.send field_name
            send(name).where(field_name.gt => position)
              .each_with_index do |object, index|
              object.update_attribute field_name, position + index
            end
          end

          meta[:order]       ||= "#{field_name} asc"
          meta[:after_add]     = relation_added_callback
          meta[:before_remove] = relation_removed_callback
        end

        private

        # Redefines a method on owner to first execute &block, then
        # continue executing original method. 
        #
        # @param [ Object ] owner  The owner of the method
        # @param [ String ] method The name of the method to override
        # @param [ Proc ]   &block The block to execute before original method
        #
        # @private
        # @since 0.0.3
        def before_method owner, method, &block
          original_method = owner.instance_method method
          owner.re_define_method method do |*args|
            self.instance_exec *args, &block
            original_method.bind(self).call *args
          end
        end

        # Redefines a method on owner to execute &block,
        # passing to it as arguments the original method and its arguments.
        # It's the callers' responsibility at that point to run whatever code
        # and return the results of the original method by calling it.
        #      
        # Use as an alternative to before_method if your override depends on the 
        # results of the original method. around_method will avoid the inevitable
        # stack overflow that occurs in before_method if you call itself.
        #
        # @param [ Object ] owner  The owner of the method
        # @param [ String ] method The name of the method to override
        # @param [ Proc ]   &block The block to execute before original method
        #
        # @private
        # @since 0.0.6
        def around_method owner, method, &block
          original_method = instance_method method
          owner.re_define_method method do |*args|
            self.instance_exec original_method, *args, &block
          end        
        end

      end # ClassMethods

    end
  end
end
