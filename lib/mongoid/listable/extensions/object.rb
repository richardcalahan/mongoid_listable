module Mongoid
  module Listable
    module Extensions

      module Object
        
        # Redefine the method. Will undef the method if it exists or simply
        # just define it.
        #
        # @example Redefine the method.
        #   Object.re_define_method("exists?") do
        #     self
        #   end
        #
        # @param [ String, Symbol ] name The name of the method.
        # @param [ Proc ] block The method body.
        #
        # @return [ Method ] The new method.
        #
        # # @since 0.0.7
        def _redefine_method name, &block
          undef_method(name) if method_defined?(name)
          define_method(name, &block)
        end

        # Redefines a method on owner to first execute &block, then
        # continue executing original method. 
        #
        # @param [ Object ] owner  The owner of the method
        # @param [ String ] method The name of the method to override
        # @param [ Proc ]   &block The block to execute before original method
        #
        # @since 0.0.3
        def before_method name, &block
          original_method = instance_method name
          _redefine_method name do |*args|
            instance_exec *args, &block
            original_method.bind(self).call *args
          end
        end

        # Redefines a method on owner to execute &block,
        # passing to it as arguments the original method and its arguments.
        # It's the callers' responsibility at that point to run whatever code
        # and return the results of the original method by calling it.
        #      
        # Use as an alternative to before_method if your override depends on 
        # the results of the original method. around_method will avoid the 
        # inevitable stack overflow that occurs in before_method 
        # if you call itself.
        #
        # @param [ Object ] owner  The owner of the method
        # @param [ String ] method The name of the method to override
        # @param [ Proc ]   &block The block to execute before original method
        #
        # @since 0.0.6
        def around_method name, &block
          original_method = instance_method name
          _redefine_method name do |*args|
            instance_exec original_method, *args, &block
          end        
        end

      end

    end
  end
end

::Object.__send__ :include, Mongoid::Listable::Extensions::Object
