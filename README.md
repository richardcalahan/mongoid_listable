# Mongoid Listable
[![Code Climate](https://codeclimate.com/repos/527c1e427e00a44bc100c7e3/badges/344ff1980ca523c67291/gpa.png)](https://codeclimate.com/repos/527c1e427e00a44bc100c7e3/feed)
[![Build Status](https://travis-ci.org/richardcalahan/mongoid_listable.png?branch=master)](https://travis-ci.org/richardcalahan/mongoid_listable)
[![Coverage Status](https://coveralls.io/repos/richardcalahan/mongoid_listable/badge.png?branch=master)](https://coveralls.io/r/richardcalahan/mongoid_listable?branch=master)
[![Gem Version](https://badge.fury.io/rb/mongoid_listable.png)](http://badge.fury.io/rb/mongoid_listable)

Mongoid Listable manages lists for isolated collections or for more complex `has_many` / `belongs_to` relationships.



## Basic Usage - Isolated

    class Photo
      include Mongoid::Document
      include Mongoid::Listable
      
      listed
    end
    
The `listed` macro will assign a `position` field and a `list` scope to the Photo class. All Photo instances 
added, updated or removed will trigger automatic reording of all sibling instances.
    
    

## Basic Usage - Has Many


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
    
In this example photos that are added to or removed from a user will maintain logical position based on the method used:

    # Default setter
    User.first.photos = [ photo_a, photo_c, photo_b ]
    User.first.photos.last == photo_b #=> true
    
    # Default ids setter
    User.first.photo_ids = [ '527fe97c67df6f07e1000003', '527fe97c67df6f07e1000004', '527fe97c67df6f07e1000003' ]
    User.first.photos[1].id == '527fe97c67df6f07e1000004' #=> true
   

Each photo that belongs to the user will automatically obtain a field called `user_position`. The position field
is derived from the foreign key of the relation, replacing "\_id" with "_position". 

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

There's a lot more to add to the library! At this point, it conveniently handles has many relationships.

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
