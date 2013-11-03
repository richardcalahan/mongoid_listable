module Mongoid

  # This module contains the core macro for defining listable has_many relationships
  # documents. They can be either embedded or referenced (relational).
  module Lists

    extend ActiveSupport::Concern

    FIELD_SUFFIX = '_position'    

    include do 
      after_add 
    end

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
        field_name = options[:column] || (meta.foreign_key.to_s.gsub(/_?id$/, FIELD_SUFFIX)).to_sym
        klass      = meta.klass        

        ids_setter_name = "#{relation.to_s.singularize}_ids="
        ids_setter      = instance_method ids_setter_name
        re_define_method ids_setter_name do |ids|
          # assign new position int
          ids.each_with_index do |id, index|
            klass.find(id).update_attribute field_name, index + 1
          end

          # unassign old position ints
          klass.where(meta.foreign_key => id).not_in(id: ids).each do |obj|
            obj.update_attribute field_name, nil
          end

          # invoke original method
          ids_setter.bind(self).call(ids)
        end

        meta[:order] = "#{field_name} asc"
      end

    end

  end

end
