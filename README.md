# Mongoid Listable
[![Code Climate](https://codeclimate.com/github/richardcalahan/mongoid_listable.png)](https://codeclimate.com/github/richardcalahan/mongoid_listable)
[![Build Status](https://travis-ci.org/richardcalahan/mongoid_listable.png?branch=master)](https://travis-ci.org/richardcalahan/mongoid_listable)
[![Coverage Status](https://coveralls.io/repos/richardcalahan/mongoid_listable/badge.png?branch=master)](https://coveralls.io/r/richardcalahan/mongoid_listable?branch=master)
[![Gem Version](https://badge.fury.io/rb/mongoid_listable.png)](http://badge.fury.io/rb/mongoid_listable)

Mongoid Listable is a library for managing listable relations. It works great for non-relational collections or for more complex `has_many` / `embeds_many` relationships.

There are two main macros:   

* `listed` for non-relational lists that do not belong to any objects.   
* `lists`  for `has_many` / `embeds_many` relationships.


## Basic Usage - Non-Relational

    class Photo
      include Mongoid::Document
      include Mongoid::Listable
      
      listed
      ...
    end
    
The `listed` macro will assign a `position` field and a `list` scope to the Photo class. All Photo instances that are
created, destroyed, or have their position field updated will trigger a reording of all sibling instances. 

Non-relational lists can have as many listed contexts as needed. You'll need to specify both the `scope` and the
`field` options in these cases.

    class Photo
      include Mongoid::Document
      include Mongoid::Listable

      listed :scope :list, field: :position
      listed :scope :slideshow, field: :slideshow_position
      ...
    end
    
    Photo.list      # orders by position field
    Photo.slideshow # orders by slideshow_position
    
    
## Basic Usage - Has Many / Embeds Many


    class User
      include Mongoid::Document
      include Mongoid:Listable
    
      has_many :photos
      # or embeds_many :photos
      
      lists :photos
      
      ...
    end
    
    class Photo
      include Mongoid::Document
      
      belongs_to :user
      # or embedded_in :user
      ...
    end
    
In this example photos that are added to or removed from a user's collection, or have their position attribute updated
will trigger a reordering of all sibling instances. For example:

    # setter
    User.first.photos = [ photo_a, photo_c, photo_b ]
    User.first.photos.last == photo_b #=> true
    
    # ids setter
    User.first.photo_ids = [ '527fe97c67df6f07e1000003', '527fe97c67df6f07e1000004', '527fe97c67df6f07e1000003' ]
    User.first.photos[1].id == '527fe97c67df6f07e1000004' #=> true
    
    # push
    photo = Photo.create
    User.first.photos << photo
    User.first.photos.last == photo #=> true
    
    

Each photo that belongs to the user will automatically obtain a field called `user_position`. The field name
is derived from the foreign key of the relation, replacing "\_id" with "_position".   

The `has_many` / `embeds_many` relationship of a user to their photos will automadtically be ordered by `user_position` unless otherwise specified
via the standard `order` option to the `has_many` macro. 
    
## Advanced Usage - Has Many / Embeds Many

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
