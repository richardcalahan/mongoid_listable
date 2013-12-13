require 'spec_helper'

describe Mongoid::Listable do   

  def ensure_order objects, field
    objects.each_with_index do |object, index|
      expect(object[field]).to eq(index + 1)
    end
  end

  describe 'listed' do 

    FIELD = :custom_field
    SCOPE = :custom_scope

    before :each do
      Item.destroy_all
      10.times { Item.create! }
    end    

    after :each do 
      ensure_order Item.send(SCOPE), FIELD
    end

    it 'should have a position field' do 
      expect(Item.fields.key?(FIELD.to_s)).to be_true
    end

    it 'should have a list scope' do 
      expect(Item.scopes.key?(SCOPE)).to be_true
    end

    it 'should append new object at position 1' do
      item = Item.create FIELD => 1
      expect(item.send(FIELD)).to eq(1)
    end

    it 'should append new object at position 5' do
      item = Item.create FIELD => 5
      expect(item.send(FIELD)).to eq(5)
    end

    it 'should append new object at end of list' do
      item = Item.create
      expect(item.send(FIELD)).to eq(11)
    end

    it 'should maintain order when removing object at position 1' do
      Item.send(SCOPE).first.destroy
    end

    it 'should maintain order when removing object at position 5' do
      Item.where(FIELD => 5).destroy
    end

    it 'should maintain order when removing object at position 10' do
      Item.send(SCOPE).last.destroy
    end

    it 'should maintain order when moving object from position 1 to 5' do
      item = Item.send(SCOPE).first
      item.update_attribute FIELD, 5
      expect(Item.send(SCOPE).where(FIELD => 5).first).to eq(item)
    end

    it 'should maintain order when moving object from position 10 to 5' do
      item = Item.send(SCOPE).last
      item.update_attribute FIELD, 5
      expect(Item.send(SCOPE).where(FIELD => 5).first).to eq(item)
    end

    it 'should maintain order when moving object from position 2 to 6' do
      item = Item.send(SCOPE).where(FIELD => 2).first
      item.update_attribute FIELD, 6
      expect(Item.send(SCOPE).where(FIELD => 6).first).to eq(item)
    end

    it 'should maintain order when moving object from position 8 to 4' do
      item = Item.send(SCOPE).where(FIELD => 8).first
      item.update_attribute FIELD, 4
      expect(Item.send(SCOPE).where(FIELD => 4).first).to eq(item)
    end

    it 'should maintain order when moving two objects\' positions' do
      item_1 = Item.send(SCOPE).where(FIELD => 8).first
      item_2 = Item.send(SCOPE).where(FIELD => 9).first
      item_1.update_attribute FIELD, 2
      item_2.update_attribute FIELD, 6
      expect(Item.send(SCOPE).where(FIELD => 2).first).to eq(item_1)
      expect(Item.send(SCOPE).where(FIELD => 6).first).to eq(item_2)
    end

    it 'should do nothing when assigning object to same position' do
      item = Item.send(SCOPE).where(FIELD => 5).first
      item.update_attribute FIELD, 5
      expect(Item.send(SCOPE).where(FIELD => 5).first).to eq(item)
    end

    it 'should compensate for updated positions that are higher than bounds' do
      item = Item.send(SCOPE).where(FIELD => 5).first
      item.update_attribute FIELD, 100
      expect(Item.send(SCOPE).last).to eq(item)
    end

    it 'should compensate for updated positions that are lower than bounds' do
      item = Item.send(SCOPE).where(FIELD => 5).first
      item.update_attribute FIELD, 0
      expect(Item.send(SCOPE).first).to eq(item)
    end

    it 'should compensate for updated positions that are nil' do 
      item = Item.send(SCOPE).where(FIELD => 5).first
      item.update_attribute FIELD, nil
      expect(Item.send(SCOPE).last).to eq(item)
    end
  end

  describe 'lists' do
    
    describe 'embedded' do

      before :each do
        Article.destroy_all
        Article.create!
        10.times { Article.first.sections.create! }
      end

      after :each do 
        ensure_order Article.first.sections, :article_position
      end

      it 'should have a position field' do 
        expect(Section.fields.key?('article_position')).to be_true
      end

      it 'should append new objects with the default setter' do 
        sections = 10.times.collect { Section.new }
        sections.reverse!
        Article.first.sections = sections

        Article.first.sections.each_with_index do |section, index|
          expect(section.id).to eq(sections[index].id)
        end
      end

      it 'should append new object at position 1' do 
        section = Article.first.sections.create article_position: 1
        expect(section.article_position).to eq(1)
      end

      it 'should append new object at position 5' do 
        section = Article.first.sections.create article_position: 5        
        expect(section.article_position).to eq(5)
      end

      it 'should append new object at end of list' do
        section = Article.first.sections.create!
        expect(section.article_position).to eq(11)
      end

      it 'should maintain order when removing object at position 1' do
        Article.first.sections.first.destroy        
      end

      it 'should maintain order when removing object at position 2' do
        section = Article.first.sections.where(article_position: 2).first
        Article.first.sections.delete(section)
      end

      it 'should maintain order when removing object at position 5' do
        Article.first.sections.where(article_position: 5).first.destroy
      end

      it 'should maintain order when removing object at position 10' do
        Article.first.sections.where(article_position: 10).first.destroy
      end

      it 'should maintain order when moving object from position 1 to 5' do
        section = Article.first.sections.where(article_position: 1).first
        section.update_attribute :article_position, 5
        expect(Article.first.sections.where(article_position: 5).first).to eq(section)
      end

      it 'should maintain order when moving object from position 10 to 5' do
        section = Article.first.sections.where(article_position: 10).first
        section.update_attribute :article_position, 5
        expect(Article.first.sections.where(article_position: 5).first).to eq(section)
      end

      it 'should maintain order when moving object from position 2 to 6' do
        section = Article.first.sections.where(article_position: 2).first
        section.update_attribute :article_position, 6
        expect(Article.first.sections.where(article_position: 6).first).to eq(section)
      end

      it 'should maintain order when moving object from position 8 to 4' do
        section = Article.first.sections.where(article_position: 8).first
        section.update_attribute :article_position, 4
        expect(Article.first.sections.where(article_position: 4).first).to eq(section)
      end

      it 'should do nothing when assigning object to same position' do
        section = Article.first.sections.where(article_position: 5).first
        section.update_attribute :article_position, 5
        expect(Article.first.sections.where(article_position: 5).first).to eq(section)
      end

      it 'should compensate for updated positions that are higher than bounds' do 
        section = Article.first.sections.where(article_position: 5).first
        section.update_attribute :article_position, 100
        expect(Article.first.sections.last).to eq(section)
      end

      it 'should compensate for updated positions that are lower than bounds' do 
        section = Article.first.sections.where(article_position: 5).first
        section.update_attribute :article_position, -100
        expect(Article.first.sections.first).to eq(section)
      end

      it 'should compensate for updated positions that are nil' do 
        section = Article.first.sections.where(article_position: 5).first
        section.update_attribute :article_position, nil
        expect(Article.first.sections.last).to eq(section)
      end
      
    end

    describe 'referenced' do

      before :each do
        User.destroy_all
        Photo.destroy_all
        User.create!
        10.times { User.first.photos.create! }
      end

      after :each do 
        ensure_order User.first.photos, :user_position
      end

      it 'should have a position field' do 
        expect(Photo.fields.key?('user_position')).to be_true
      end

      it 'should append new object at position 1' do 
        photo = User.first.photos.create user_position: 1
        expect(photo.user_position).to eq(1)
      end

      it 'should append new object at position 5' do 
        photo = User.first.photos.create user_position: 5
        expect(photo.user_position).to eq(5)
      end

      it 'should append new object at end of list' do
        user = User.first.photos.create!
        expect(user.user_position).to eq(11)
      end

      it 'should add new objects with the default setter' do
        photos = 15.times.collect { Photo.create }

        photos.reverse!

        User.first.photos = photos
        
        expect(User.first.photos.count).to eq(15)

        User.first.photos.each_with_index do |photo, index|
          expect(photos[index].id).to eq(photo.id)
        end
      end

      it 'should add new objects with the default ids setter' do
        ids = 15.times.collect { Photo.create.id }

        User.first.photo_ids = ids
        expect(User.first.photos.count).to eq(15)

        User.first.photos.each_with_index do |photo, index|
          expect(ids[index]).to eq(User.first.photos[index].id)
        end
      end

      it 'should maintain order when removing object at position 1' do
        User.first.photos.first.destroy        
      end

      it 'should maintain order when removing object at position 2' do
        photo = User.first.photos.where(user_position: 2).first
        User.first.photos.delete(photo)
      end

      it 'should maintain order when removing object at position 5' do
        User.first.photos.where(user_position: 5).first.destroy
      end

      it 'should maintain order when removing object at position 10' do
        User.first.photos.where(user_position: 10).first.destroy
      end

      it 'should maintain order when moving object from position 1 to 5' do
        photo = User.first.photos.where(user_position: 1).first
        photo.update_attribute :user_position, 5
        expect(User.first.photos.where(user_position: 5).first).to eq(photo)
      end

      it 'should maintain order when moving object from position 10 to 5' do
        photo = User.first.photos.where(user_position: 10).first
        photo.update_attribute :user_position, 5
        expect(User.first.photos.where(user_position: 5).first).to eq(photo)
      end

      it 'should maintain order when moving object from position 2 to 6' do
        photo = User.first.photos.where(user_position: 2).first
        photo.update_attribute :user_position, 6
        expect(User.first.photos.where(user_position: 6).first).to eq(photo)
      end

      it 'should maintain order when moving object from position 8 to 4' do
        photo = User.first.photos.where(user_position: 8).first
        photo.update_attribute :user_position, 4
        expect(User.first.photos.where(user_position: 4).first).to eq(photo)
      end

      it 'should do nothing when assigning object to same position' do
        photo = User.first.photos.where(user_position: 5).first
        photo.update_attribute :user_position, 5
        expect(User.first.photos.where(user_position: 5).first).to eq(photo)
      end

      it 'should compensate for updated positions that are higher than bounds' do 
        photo = User.first.photos.where(user_position: 5).first
        photo.update_attribute :user_position, 100
        expect(User.first.photos.last).to eq(photo)
      end

      it 'should compensate for updated positions that are lower than bounds' do 
        photo = User.first.photos.where(user_position: 5).first
        photo.update_attribute :user_position, -100
        expect(User.first.photos.first).to eq(photo)
      end

      it 'should compensate for updated positions that are nil' do 
        photo = User.first.photos.where(user_position: 5).first
        photo.update_attribute :user_position, nil
        expect(User.first.photos.last).to eq(photo)
      end

    end

  end

end
