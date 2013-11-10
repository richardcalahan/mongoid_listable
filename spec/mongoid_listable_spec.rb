require 'spec_helper'

describe Mongoid::Listable do 

  before :all do 
    User.create!    
    10.times { Photo.create }
  end  

  it 'created a user' do
    expect(User.first).to be_true
  end

  it 'created 10 photos' do    
    expect(Photo.count).to eq(10)
  end

  it 'added the position field for a photo' do 
    expect(Photo.instance_methods.include?(:position)).to be_true
  end

  it 'orders photos' do 
    Photo.list.each_with_index do |photo, index|
      expect(photo.position).to eq(index + 1)
    end
  end

  it 'updates photo order on position change higher' do
    photo_a_id = Photo.list[3].id
    photo_b_id = Photo.list[7].id

    expect(Photo.find(photo_a_id).position).to eq(4)
    expect(Photo.find(photo_b_id).position).to eq(8)

    Photo.find(photo_a_id).update_attribute :position, 9

    expect(Photo.find(photo_a_id).position).to eq(9)
    expect(Photo.find(photo_b_id).position).to eq(7)
  end

  it 'updates photo order on position change lower' do
    photo_a_id = Photo.list[5].id
    photo_b_id = Photo.list[9].id

    expect(Photo.find(photo_a_id).position).to eq(6)
    expect(Photo.find(photo_b_id).position).to eq(10)

    Photo.find(photo_a_id).update_attribute :position, 2

    expect(Photo.find(photo_a_id).position).to eq(2)
    expect(Photo.find(photo_b_id).position).to eq(10)
  end

  it 'ensures only valid position changes' do
    photo_a_id = Photo.list[5].id
    Photo.find(photo_a_id).update_attribute :position, 400
    expect(Photo.find(photo_a_id).position).to eq(10)
    Photo.find(photo_a_id).update_attribute :position, -2
    expect(Photo.find(photo_a_id).position).to eq(1)
  end

  it 'updates photo order on photo destroy' do
    photo_a_id = Photo.list[5].id
    photo_b_id = Photo.list[9].id

    expect(Photo.find(photo_b_id).position).to eq(10)

    Photo.find(photo_a_id).destroy

    expect(Photo.find(photo_b_id).position).to eq(9)
  end

  it 'creates a new photo' do
    Photo.create
    expect(Photo.all.count).to eq(10)
    expect(Photo.last.position).to eq(10)
  end

  it 'adds photos to a user with the default setter' do 
    User.first.photos = Photo.all
    expect(User.first.photos.count).to eq(10)
  end

  it 'orders photos for a user' do 
    User.first.photos.each_with_index do |photo, index|
      expect(photo.user_position).to eq(index + 1)
    end
  end

  it 'removes photos from a user' do 
    User.first.photos = nil
    expect(User.first.photos.count).to eq(0)
  end

  it 'adds 5 photos to a user with the default ids setter' do
    User.first.photo_ids = Photo.all[0..4].map &:id
    expect(User.first.photos.count).to eq(5)
  end

  it 'adds all photos to a user with the default ids setter' do
    User.first.photo_ids = Photo.all.map &:id
    expect(User.first.photos.count).to eq(10)
  end

  it 'orders photos for a user' do 
    User.first.photos.each_with_index do |photo, index|
      expect(photo.user_position).to eq(index + 1)
    end
  end

  it 'adds a new photo to a user' do 
    User.first.photos << Photo.new
    expect(User.first.photos.count).to eq(11)
    expect(User.first.photos.last.user_position).to eq(11)
  end

  it 'adds a created photo to a user' do 
    User.first.photos << Photo.create
    expect(User.first.photos.count).to eq(12)
    expect(User.first.photos.last.user_position).to eq(12)
  end

  it 'deletes a photo from a user' do 
    User.first.photos.delete(Photo.all[5])
    expect(User.first.photos.count).to eq(11)
    expect(User.first.photos.last.user_position).to eq(11)
  end

  it 'orders photos for a user' do 
    User.first.photos.each_with_index do |photo, index|
      expect(photo.user_position).to eq(index + 1)
    end
  end

end
