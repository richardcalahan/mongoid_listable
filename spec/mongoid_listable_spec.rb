require 'spec_helper'

describe Mongoid::Listable do 

  before :all do 
    @user = User.create!
    @photos = []
    10.times { @photos << Photo.create }
  end  

  it 'created a user' do
    expect(@user).to be_true
  end

  it 'created 10 photos' do    
    expect(@photos.count).to eq(10)
  end

  it 'assigns all photos to a user with the default setter' do 
    @user.photos = @photos
    expect(@user.photos.count).to eq(@photos.count)
  end

  it 'assigns all photos to a user with the default ids setter' do 
    ids = @photos.collect(&:id)
    @user.photo_ids = ids
    expect(@user.photos.count).to eq(@photos.count)
  end

  it 'removes a photo from a user using the delete method' do 
    @user.photos.delete @photos[0]
    expect(@user.photos.count).to eq(@photos.count - 1)
  end

  it 'removes a photo from a user using the default setter' do 
    @user.photos = @photos[0..4]
    expect(@user.photos.count).to eq(@photos.count - 5)
  end

  it 'updated the position field for all the photos' do 
    User.first.photos.each_with_index do |photo, index|
      expect(photo.user_position).to eq(index + 1)
    end
  end

end
