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
          configuration = { field_name: :position }
          configuration.merge! options if options.is_a?(Hash)

          field_name = configuration[:field_name]

          field field_name, type: Integer

          created(field_name).updated(field_name).destroyed(field_name)

          scope :list, order_by(field_name => :asc)
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
        def lists name, options={}
          meta = reflect_on_association name
          field_name = field_name(meta)
          meta.klass.send :field, field_name, type: Integer
          ids_set(name, meta).set(name, meta)
            .added(name, meta).removed(name, meta)

          meta.klass.updated(field_name).destroyed(field_name)

          meta[:order] ||= "#{field_name(meta)} asc"
        end

      end

    end
  end
end
