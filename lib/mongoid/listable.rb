module Mongoid
  
  module Listable

    extend ActiveSupport::Concern

    included do 
      puts "yay!"
      puts metadata
    end

  end

end
