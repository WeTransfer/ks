# frozen_string_literal: true

require 'set'

# "Ks" - as in "kiss" - a generator of keyworded Structs.
module Ks
  VERSION = '0.0.2'

  @@caching_mutex = Mutex.new
  @@predefined_structs = {}

  # Returns a class that is a descendant of Struct, with a strict
  # keyword initializer.
  #
  #     Info = Ks.strict(:item_count, :weight)
  #     data = Info.new(item_count: 1, weight: 2)
  #
  # Note that all the keyword arguments defined for the class (all the members)
  # are going to be required keyword arguments for the initializer.
  #
  # The created classes (Struct descendants) are cached
  # to make reloading easier, since when reloading a usual Struct
  # descendant it will receive a different parent class.
  # This is mitigated by caching the created subclasses using their member lists
  #
  # @param members[Array<Symbol>] the names of members to create
  # @return created_class[Class]
  def self.strict(*members)
    k = members.sort.join(':')
    @@caching_mutex.synchronize do
      return @@predefined_structs[k] if @@predefined_structs[k]

      struct_ancestor = Struct.new(*members) do
        def self.new(*args, **kwargs)
          instance = allocate
          instance.send(:initialize, *args, **kwargs)
          instance
        end
      end

      predefined = Class.new(struct_ancestor) do
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def initialize(#{members.map { |a| "#{a}:" }.join(', ')}) # def initialize(bar:, baz:)
            super(#{members.join(', ')})                            #   super(bar, baz)
          end                                                       # end
        METHOD
      end
      @@predefined_structs[k] = predefined
      predefined
    end
  end

  # Returns a class that is a descendant of Struct, with a
  # keyword initializer that permits unknown keywords to be passed in.
  # Those keywords will be dropped. The keywords that are known at
  # definition time will be checked for presence. This allows you to
  # use structs for API responses and payloads that might get additional
  # properties as the API evolves, without breaking (your) consuming
  # code. Imagine at time of designing your structures you specify a
  # Shipment:
  #
  #     Shipment = Ks.allowing_unknown(:sku, :weight)
  #
  # The API you are using, however, later adds a "shipping_company_id"
  # property. If you had used `strict` your struct would fail to initialize,
  # since it does not know about the `shipping_company_id` attribute.
  #
  #    Shipment.new(JSON.parse(payload)) #=> ArgumentError...
  #
  # but as you have used `allowing_unknown` the "shipping_company_id" property
  # will be silently dropped instead.
  #
  # The created classes (Struct descendants) are cached
  # to make reloading easier, since when reloading a usual Struct
  # descendant it will receive a different parent class.
  # This is mitigated by caching the created subclasses using their member lists
  #
  # @param members[Array<Symbol>] the names of members to create. Those members will be required, just like with `Ks.strict`
  # @return created_class[Class]
  def self.allowing_unknown(*members)
    k = 'with_optionals:' + members.sort.join(':')
    @@caching_mutex.synchronize do
      return @@predefined_structs[k] if @@predefined_structs[k]

      struct_ancestor = Struct.new(*members) do
        def self.new(*args, **kwargs)
          instance = allocate
          instance.send(:initialize, *args, **kwargs)
          instance
        end
      end

      predefined = Class.new(struct_ancestor) do
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def initialize(#{members.map { |a| "#{a}:" }.join(', ')}, **) # def initialize(bar:, baz:, **)
            super(#{members.join(', ')})                                #   super(bar, baz)
          end                                                           # end
        METHOD
      end
      @@predefined_structs[k] = predefined
      predefined
    end
  end
end
