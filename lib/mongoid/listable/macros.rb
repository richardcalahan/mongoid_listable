module Mongoid
  module Listable

    # This module contains the core macro for defining listable 
    # has_many relationships
    module Macros

      # Macro to set relation on which to make a list
      #
      # @param [ Symbol ] relation The name of the has_many relation
      # @param [ Hash ]   options The options hash
      #
      # @return [ Mongoid:Relations:Metadata ] Instance of metadata for the 
      # relation
      #
      # @since 0.0.1
      def lists name, options={}
        meta       = reflect_on_association name
        field_name = options[:column] || 
          (meta.foreign_key.to_s.gsub(/_?id$/, '_position')).to_sym
        
        # Override the default ids setter, first setting the correct position
        # on each relation based on the index of its id in the given array.
        #
        # @override model#{name}_ids= 
        before_method self, "#{name.to_s.singularize}_ids=" do |ids|
          ids.each_with_index do |id, index|
            meta.klass.find(id).update_attribute field_name, index + 1
          end
        end

        meta[:order] ||= "#{field_name} asc"
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
        original_method = instance_method method
        owner.re_define_method method do |*args|
          block.call *args
          original_method.bind(self).call *args
        end
      end      

    end
  end
end
