module Mongoid
  module Listable
    
    module Accessors
      extend ActiveSupport::Concern

      module ClassMethods

        # Redefines the default ids setter, ensuring that the order of 
        # objects sent to the relation setter corresponds to the order
        # of the array of ids
        #
        # @override model#{name}_ids=
        def _ids_setter name, meta
          ids_method = "#{name.to_s.singularize}_ids="
          redefine_method ids_method do |ids|            
            send meta.setter, meta.klass.find(ids).sort_by_attr(:id, ids)
          end
          self
        end

        # Prepends to the default setter a block that sets the position
        # attribute on each object according to its index in the array
        #
        # @override model#{name}=
        def _setter name, meta
          before_method self, "#{name}=" do |objects|
            objects.each_with_index do |object, index|
              object.update_attribute field_name(meta), index + 1
            end

            (send(name).to_a - objects).each do |object|
              object.unset field_name(meta)
            end
          end
          self
        end

        def field_name meta
          (meta.foreign_key.to_s.gsub(/_?id$/, '_position')).to_sym
        end

        private

      end # ClassMethods

      def field_name name
        self.class.field_name name
      end

    end

  end
end
