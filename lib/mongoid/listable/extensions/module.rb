module Mongoid
  module Listable
    module Extensions

      module Module
        
        # Redefines a method on owner to first execute &block, then
        # continue executing original method. 
        #
        # @param [ Object ] owner  The owner of the method
        # @param [ String ] method The name of the method to override
        # @param [ Proc ]   &block The block to execute before original method
        #
        # @since 0.0.3
        def before_method owner, method, &block
          original_method = owner.instance_method method
          owner.re_define_method method do |*args|
            self.instance_exec *args, &block
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
        def around_method owner, method, &block
          original_method = instance_method method
          owner.re_define_method method do |*args|
            self.instance_exec original_method, *args, &block
          end        
        end

      end

    end
  end
end

::Module.__send__ :include, Mongoid::Listable::Extensions::Module
