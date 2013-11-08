module Mongoid
  module Listable
    module Extensions
      
      module Array

        def sort_by_attr k, v
          v.reject! &:blank?
          sort { |a, b| v.index(a.send(k)) <=> v.index(b.send(k)) }
        end

      end

    end
  end
end

::Array.__send__ :include, Mongoid::Listable::Extensions::Array
