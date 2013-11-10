module Mongoid
  module Listable
    
    module Accessors
      extend ActiveSupport::Concern

      module ClassMethods

        # Redefines the default ids setter, ensuring that the order of 
        # objects sent to the relation setter corresponds to the order
        # of the array of ids
        #
        # @param [ Symbol ]   name The name of the has_many relation
        # @param [ MetaData ] meta The MetaData class
        #
        # @return [ Object ] self
        #
        # @since 0.0.6
        def ids_set name, meta
          ids_method = "#{name.to_s.singularize}_ids="
          redefine_method ids_method do |ids|            
            send meta.setter, meta.klass.find(ids).sort_by_attr(:id, ids)
          end
          self
        end

        # Prepends to the default setter a block that sets the position
        # attribute on each object according to its index in the array
        #
        # @param [ Symbol ]   name The name of the has_many relation
        # @param [ MetaData ] meta The MetaData class
        #
        # @return [ Object ] self
        #
        # @since 0.0.6
        def set name, meta
          before_method "#{name}=" do |objects|
            objects ||= []
            objects.each_with_index do |object, index|
              object.set field_name(meta), index + 1
            end

            (send(name).to_a - objects).each do |object|
              object.unset field_name(meta)
            end
          end
          self
        end

      end

    end

  end
end
