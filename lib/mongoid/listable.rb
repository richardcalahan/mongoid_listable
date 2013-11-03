module Mongoid
  
  module Listable

    extend ActiveSupport::Concern

    FIELD_SUFFIX = '_position'

    included do
      
    end

    module ClassMethods      

      def listable options={}
        configuration = {
          scope: nil,
          column: :position          
        }

        configuration.merge! options
          
        field options[:column] || 
          column_from_meta(reflect_on_association(relation)), 
        type: Integer        
      end
      
      def column_from_meta meta
        if meta[:foreign_key]
          meta[:foreign_key].to_s.gsub /_?id$/, FIELD_SUFFIX
        else
          meta[:name].to_s + FIELD_SUFFIX
        end
      end
      
      def register_listable relation
        listables << relation 
      end

      def listables
        @@listables ||= []
      end

    end

  end

end
