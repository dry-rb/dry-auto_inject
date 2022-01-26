# frozen_string_literal: true

RSpec.describe 'methods' do
  it 'defines methods returning dependencies' do
    module Test
      AutoInject = Dry::AutoInject(one: 'dep 1', two: 'dep 2').methods
    end

    obj = Class.new do
      include Test::AutoInject[:one, :two]
    end

    expect(obj.one).to eq 'dep 1'
    expect(obj.new.one).to eq 'dep 1'
    expect(obj.two).to eq 'dep 2'
    expect(obj.new.two).to eq 'dep 2'

    other_obj = obj.with_deps(one: 'other dep 1')
    expect(other_obj.one).to eq 'other dep 1'
    expect(other_obj.new.one).to eq 'other dep 1'
    expect(other_obj.two).to eq 'dep 2'
    expect(other_obj.new.two).to eq 'dep 2'
  end
end
