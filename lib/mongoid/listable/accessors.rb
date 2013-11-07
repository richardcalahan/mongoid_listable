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
           ids.map! &:to_s
           objects = meta.klass.find(ids.reject(&:blank?)).sort! do |a, b|
             ids.index(a.id.to_s) <=> ids.index(b.id.to_s)
           end
           send meta.setter, objects
           self
         end
       end

     end # ClassMethods

   end

 end
end
