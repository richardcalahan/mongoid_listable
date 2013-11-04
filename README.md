# Mongoid Listable

Mongoid Listable will eventually be a full replacement library for Mongoid List or Mongoid Orderable. Both 
libraries fail to accomplish the simple task this library handles: listable children that need to be specific for a 
given `has_many` / `belongs_to` relation.

## Basic Usage

    class User
      include Mongoid::Document
      include Mongoid:Lists
    
      has_many :photos
      lists :photos
      ...
    end
    
    class Photo
      include Mongoid::Document
      
      belongs_to :user
      ...
    end
    
    User.first.photo_ids=["5275428767df6fba82000002", "5275428d67df6fea66000004", ... ]
    
## Complex Relations

    # Handles multiple has many relations on same model!
    
    class User
      include Mongoid::Document
      include Mongoid:Lists
    
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
      class_name
      
      ...
    end
    
    User.first.photo_ids=["5275428767df6fba82000002", "5275428d67df6fea66000004", ... ]
    
Photos that are assigned to a user via by the method `user.photo_ids=[ids]` will maintain position based on the index
of the id in the array argument.

Each photo that belongs to the user will automatically obtain a field called `user_position`. The position field
is derived from the foreign key of the relation, replacing "_id" with "_position". 

The 1-n relation of a user to their photos will automatically be ordered by `user_position` unless otherwise specified. 

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
