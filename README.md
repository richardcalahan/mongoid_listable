# Mongoid Listable

Mongoid Listable will eventually be a full replacement library for Mongoid List or Mongoid Orderable. Both 
libraries fail to accomplish the simple task this library handles: lists that need to be specific for a given `has_many`
relation.


## Installation

Add this line to your application's Gemfile:

    gem 'mongoid_listable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid_listable

## Usage

    class User
      include Mongoid::Document
      include Mongoid:Listable
    
      has_many :photos
      
      lists :photos
    
    end

    

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
