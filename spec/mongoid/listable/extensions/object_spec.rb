require 'spec_helper'

describe Mongoid::Listable::Extensions::Object do 

  before :each do 

    class Object
      @@foo = 1
      def foo
        @@foo
      end
      def foo= foo
        @@foo = foo
      end
    end

  end

  it 'allows a block to be executed before a method' do
    Object.before_method "foo" do
      self.foo = 2
    end

    expect(Object.new.foo).to eq(2)
  end

  it 'allows a block to be executed around a method' do
    original_method       = nil
    original_return_value = nil
    Object.around_method "foo" do |method, *args|
      original_method = method
      original_return_value = method.bind(self).call *args
    end

    Object.new.foo

    expect(original_method).to be_a_kind_of(UnboundMethod)    
    expect(original_return_value).to eq(1)
  end

end
