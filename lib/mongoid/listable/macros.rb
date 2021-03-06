module Mongoid
  module Listable

    # This module contains the core macro for defining listable 
    # has_many relationships
    module Macros
      extend ActiveSupport::Concern

      module ClassMethods

        # Macro to set basic position field on an object
        #
        # @param [ Hash ]   options The options hash
        #
        # @return self
        #
        # @since 0.1.0
        def listed options={}
          config = { 
            field: :position,
            scope: :list 
          }

          config.merge! options

          field config[:field], type: Integer

          created   config[:field]
          updated   config[:field]
          destroyed config[:field]

          scope config[:scope], order_by(config[:field] => :asc)

          self
        end

        # Macro to set relation on which to make a list
        #
        # @param [ Symbol ] name The name of the has_many relation
        # @param [ Hash ]   options The options hash
        #
        # @return [ Mongoid:Relations:Metadata ] Instance of metadata
        #
        # @since 0.0.1
        def lists association, options={}
          meta       = reflect_on_association association
          field_name = determine_position_field_name meta

          meta.klass.send :field, field_name, type: Integer

          ids_set association, meta
          set     association, meta
          added   association, meta
          removed association, meta

          meta.klass.send :include, Mongoid::Listable
          meta.klass.updated(field_name).destroyed(field_name)

          meta[:order] ||= "#{field_name} asc"
        end

      end

    end
  end
end
