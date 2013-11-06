# Mongoid Listable

Mongoid Listable will eventually be a full replacement library for Mongoid List or Mongoid Orderable. Both 
libraries fail to accomplish the simple task this library handles: separate position scopes for each
defined `has_many` / `belongs_to` relation.

## Basic Usage

    class User
      include Mongoid::Document
      include Mongoid:Listable
    
      has_many :photos
      lists :photos
      ...
    end
    
    class Photo
      include Mongoid::Document
      
      belongs_to :user
      ...
    end
    
In this example photos that are assigned to a user via by the method `user.photo_ids=[ids]` will maintain position based on the index
of the id in the array argument.

Each photo that belongs to the user will automatically obtain a field called `user_position`. The position field
is derived from the foreign key of the relation, replacing "_id" with "_position". 

The 1-n relation of a user to their photos will automatically be ordered by `user_position` unless otherwise specified
via the standard `order` option to the `has_many` macro. 
    
## Complex Relations

    # Handles multiple has_many relations on same model!
    
    class User
      include Mongoid::Document
      include Mongoid:Listable
    
      has_many :featured_photos, 
      class_name: 'Photo', 
      inverse_of: :featured_by_user, 
      foreign_key: :featured_by_user_id
      
      has_many :kodak_moments, 
      class_name: 'Photo', 
      inverse_of: :kodaked_by_user, 
      foreign_key: :kodaked_by_user_id
      
      lists :featured_photos
      lists :kodak_moments
      ...
    end
    
    class Photo
      include Mongoid::Document
      
      belongs_to :featured_by_user, 
      class_name: 'User', 
      inverse_of: featured_photos, 
      foreign_key: :featured_by_user_id
      
      belongs_to :kodaked_by_user, 
      class_name: 'User', 
      inverse_of: kodak_moments, 
      foreign_key: :kodaked_by_user_id
      ...
    end
    
    
In this example, there are two `has_many` relations defined between a user and photos. Each photo belonging to a user will 
obtain two position fields: `featured_by_user_position` and `kodaked_by_user_position`.

You can optionally override the name of the position column:

    lists :photos, column: :users_photos_order

## Todo

There's a lot more to add to the library! At this point, it conveniently handles standard rails-based multiselect form fields.

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
