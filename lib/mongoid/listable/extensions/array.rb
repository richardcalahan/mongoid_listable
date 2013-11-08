module Mongoid
  module Listable
    module Extensions
      
      module Array

        # Sorts an array of objects on the specified key, sorted
        # by the order of the key in an array. Example:
        #
        # [{name: 'Richard'}, 
        #  {name: 'Ashley'}, 
        #  {name: 'Chris'}].sort_by_attr(:name, ['Chris', 'Richard', 'Ashley'])
        # 
        # => [{name: 'Chris'}, {name: 'Richard'}, {name: 'Ashley'}]
        #
        # @param [String|Symbol] key    The object attribute to sort by
        # @param [Array]         values An array of object attributes
        #
        # @return Array
        #
        # @since 0.0.6
        def sort_by_attr k, v
          v.reject! &:blank?
          sort { |a, b| v.index(a.send(k)) <=> v.index(b.send(k)) }
        end

      end

    end
  end
end

::Array.__send__ :include, Mongoid::Listable::Extensions::Array
