module Mongoid

  # This module contains the core macro for defining listable has_many relationships
  # documents. They can be either embedded or referenced (relational).
  module Lists

    extend ActiveSupport::Concern

    module ClassMethods

      # Macro to set relation on which to make a list
      #
      # @param [ Symbol ] relation The name of the has_many relation
      # @param [ Hash ] options The options hash
      #
      # @return [ Mongoid:Relations:Metadata ] Instance of metadata for the relation
      #
      # @since 0.0.1
      def lists relation, options={}
        meta       = reflect_on_association relation
        field_name = options[:column] || 
          (meta.foreign_key.to_s.gsub(/_?id$/, '_position')).to_sym
        

        # Override model#{name}_ids=        
        before_method self, "#{relation.to_s.singularize}_ids=" do |ids|
          ids.each_with_index do |id, index|
            meta.klass.find(id).update_attribute field_name, index + 1
          end

          meta.klass.where(meta.foreign_key => id).not_in(id: ids).each do |obj|
            obj.update_attribute field_name, nil
          end
        end

        meta[:order] = "#{field_name} asc"
      end

      private

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
