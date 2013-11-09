require 'spec_helper'

describe Mongoid::Listable do 

  before do 
    @user = User.create!
  end

  it 'created a user' do
    expect(@user).to be_true
  end

  it 'created 10 photos' do
    photos = []
    10.times { photos << Photo.create }
    expect(photos.count).to eq(10)
  end

  it 'assigns all photos to a user' do 

  end

end
