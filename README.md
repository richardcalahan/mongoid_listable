# Mongoid Listable

Mongoid Listable will eventually be a full replacement library for Mongoid List or Mongoid Orderable. Both 
libraries fail to accomplish the simple task this library handles: lists that need to be specific for a given `has_many`
relation.

## Usage

    class User
      include Mongoid::Document
      include Mongoid:Listable
    
      has_many :photos
      
      lists :photos
    
    end
    
    class Photo
      include Mongoid::Document
      
      belongs_to :user
    
    end
    
Now, photos that are assigned to a user via by the method `user.photo_ids=[ids]` will maintain position based on the index
of the id in the array argument.

In this example, each photo object that belongs to the user will obtain a field called `user_position`. The 1-n relation of 
a user to their photos will automatically be ordered by `user_position` unless otherwise specified. 

You can also override the name of the position column:

    lists :photos, column: :users_photos_order

There's a lot more to add to the library. At this point, it will conveniently handle rails based multiselect form fields.  

## Installation

Add this line to your application's Gemfile:

    gem 'mongoid_listable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid_listable

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
