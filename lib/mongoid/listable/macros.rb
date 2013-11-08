module Mongoid
  module Listable

    # This module contains the core macro for defining listable 
    # has_many relationships
    module Macros
      extend ActiveSupport::Concern

      module ClassMethods

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
          meta.klass.send :field, field_name(meta), type: Integer
          _ids_setter(name, meta)
            ._setter(name, meta)
            .added(name, meta)
            .removed(name, meta)
          meta[:order] ||= "#{field_name(meta)} asc"
        end

      end

    end
  end
end
