module Mongoid

  # This module contains the core macro for defining listable has_many relationships
  # documents. They can be either embedded or referenced (relational).
  module Lists

    extend ActiveSupport::Concern

    FIELD_SUFFIX = '_position'

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
        field_name = options[:column] || (meta[:name].to_s + FIELD_SUFFIX).to_sym
        klass      = meta.klass

        re_define_method "#{relation.to_s.singularize}_ids=" do |ids|
          ids.each_with_index do |id, index|
            klass.find(id).update_attribute field_name, index + 1
          end

          send(meta.setter, klass.find(ids.reject(&:blank?)))
        end

        meta[:order] = "#{field_name} asc"
      end

    end

  end

end
