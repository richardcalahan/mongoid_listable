require 'spec_helper'

describe Mongoid::Listable do   

  def ensure_order objects, field
    objects.each_with_index do |object, index|
      expect(object[field]).to eq(index + 1)
    end
  end

  describe 'listed' do 

    before :all do
      Photo.destroy_all
      10.times { Photo.create }
    end

    after :each do 
      ensure_order Photo.list, :position
    end

    it 'adds an object to the beginning of a list on create' do 
      photo = Photo.create position: 1
      expect(Photo.list.first.position).to eq(1)
      expect(photo.id).to eq(Photo.list.first.id)
    end

    it 'adds an object to the middle of a list on create' do 
      photo = Photo.create position: 5
      expect(Photo.list[4].position).to eq(5)
      expect(photo.id).to eq(Photo.list[4].id)
    end

    it 'adds an object to the end of a list on create' do 
      photo = Photo.create
      expect(Photo.list.last.position).to eq(13)
      expect(photo.id).to eq(Photo.list.last.id)
    end

    it 'updates the position of an object higher' do 
      photo_id = Photo.list[1].id
      Photo.list[1].update_attribute :position, 4
      expect(photo_id).to eq(Photo.list[3].id)
      expect(Photo.list[3].position).to eq(4)
    end

    it 'updates the position of an object lower' do 
      photo_id = Photo.list[9].id
      Photo.list[9].update_attribute :position, 2
      expect(photo_id).to eq(Photo.list[1].id)
      expect(Photo.list[1].position).to eq(2)      
    end

    it 'updates the position of an object the same' do 
      photo_id = Photo.list[4].id
      Photo.list[4].update_attribute :position, 5
      expect(photo_id).to eq(Photo.list[4].id)
      expect(Photo.list[4].position).to eq(5)      
    end

    it 'removes an object from the beginning of a list on destroy' do 
      Photo.list.first.destroy
      expect(Photo.list.first.position).to eq(1)
    end

    it 'removes an object from the middle of a list on destroy' do 
      Photo.list[6].destroy
      expect(Photo.list.first.position).to eq(1)
      expect(Photo.list[6].position).to eq(7)
      expect(Photo.list.last.position).to eq(11)
    end

    it 'removes an object from the end of a list on destroy' do 
      Photo.list.last.destroy
      expect(Photo.list.last.position).to eq(10)
    end
  end

  describe 'lists' do 

    before :all do
      User.destroy_all
      Photo.destroy_all

      User.create
      10.times { Photo.create }
    end

    after :each do 
      ensure_order User.first.photos, :user_position
    end

    it 'sets object list of an owner with the default setter' do
      photos = Photo.all
      User.first.photos = photos
      photos.each_with_index do |photo, index|
        expect(photo.id).to eq(User.first.photos[index].id)
      end
      expect(User.first.photos.count).to eq(Photo.count)
    end

    it 'sets object list of an owner with the default ids setter' do 
      ids = Photo.all[2..7].collect(&:id)
      User.first.photo_ids = ids
      ids.each_with_index do |id, index|
        expect(id).to eq(User.first.photos[index].id)
      end
      expect(User.first.photos.count).to eq(6)
    end

    it 'pushes objects to the list of an owner' do 
      User.first.photos << Photo.all
      expect(User.first.photos.count).to eq(10)
    end

    it 'updates the position of an object higher' do 
      photo_id = User.first.photos[4].id
      Photo.find(photo_id).update_attribute :user_position, 6
      expect(photo_id).to eq(User.first.photos[5].id)
      expect(User.first.photos[5].user_position).to eq(6)
    end

    it 'updates the position of an object lower' do 
      photo_id = User.first.photos[4].id
      Photo.find(photo_id).update_attribute :user_position, 1
      expect(photo_id).to eq(User.first.photos[0].id)
      expect(User.first.photos[0].user_position).to eq(1)
    end

    it 'updates the position of an object the same' do 
      photo_id = User.first.photos[4].id
      Photo.find(photo_id).update_attribute :user_position, 5
      expect(photo_id).to eq(User.first.photos[4].id)
      expect(User.first.photos[4].user_position).to eq(5)
    end

    it 'updates the position of an object out of bounds high' do 
      photo_id = User.first.photos[4].id
      Photo.find(photo_id).update_attribute :user_position, 1000
      expect(photo_id).to eq(User.first.photos.last.id)
      expect(User.first.photos.last.user_position).to eq(User.first.photos.count)
    end

    it 'updates the position of an object out of bounds low' do 
      photo_id = User.first.photos[4].id
      Photo.find(photo_id).update_attribute :user_position, -2
      expect(photo_id).to eq(User.first.photos.first.id)
      expect(User.first.photos.first.user_position).to eq(1)
    end

    it 'removes objects from the list of an owner with the default unsetter' do 
      User.first.photos.delete(Photo.first)
      expect(User.first.photos.count).to eq(9)
    end

    it 'removes objects from the list of an owner by destroy' do 
      Photo.all[3].destroy
      expect(User.first.photos.count).to eq(8)
      Photo.first.destroy
    end
  end

end
