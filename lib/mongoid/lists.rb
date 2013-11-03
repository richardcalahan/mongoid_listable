module Mongoid

  module Lists

    extend ActiveSupport::Concern

    module ClassMethods

      def lists relation, options={}
        puts "lists"
      end

    end

  end

end
