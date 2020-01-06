# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Ks' do
  describe '.strict' do
    it 'allocates a Struct class that can be initialized with keywords' do
      k = Ks.strict(:foo, :bar)
      item = k.new(foo: 1, bar: 2)
      expect(item.foo).to eq(1)
      expect(item.bar).to eq(2)
      expect(item.class.ancestors).to include(Struct)
      expect(item.members).to eq(%i[foo bar])
    end

    it 'raises when keyword arguments are omitted' do
      k = Ks.strict(:foo, :bar)
      expect do
        k.new(foo: 1)
      end.to raise_error(ArgumentError, 'missing keyword: :bar')
    end

    it 'caches the created Struct ancestor even when using multiple threads' do
      classes = (1..12).map do
        Thread.new { Ks.strict(:one, :another) }
      end.map(&:join).map(&:value)
      expect(classes.uniq.length).to eq(1)
    end
  end

  describe '.allowing_unknown' do
    it 'allocates a Struct class that can be initialized with keywords' do
      k = Ks.allowing_unknown(:foo, :bar)
      item = k.new(foo: 1, bar: 2, tang: "knip")
      expect(item.foo).to eq(1)
      expect(item.bar).to eq(2)
      expect(item.class.ancestors).to include(Struct)
      expect(item.members).to eq(%i[foo bar])
    end
  end
end
