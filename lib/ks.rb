# frozen_string_literal: true

require 'set'

# "Ks" - as in "kiss" - a generator of keyworded Structs.
module Ks
  VERSION = '0.0.1'

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

      struct_ancestor = Struct.new(*members)
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
end
