**Notice: this library is no longer maintained as there is a builtin feature for this - we recommend you use the new syntax of `Stuct.new(:name, :surname, keyword_init: true)` available in the newer Ruby versions.**

# ks - a generator for keyworded Structs

Normally when you create a Struct in Ruby you get a positional arguments
initializer.

    S = Struct.new(:a, :b)
    S.new(1, 2)

This gem allows for creation of Structs that accept keyword arguments in the same way.

    S = Ks.strict(:a, :b)
    S.new(a: 1, b: 2)

The resulting Struct will complain if you omit some keyword arguments, and will take care
of handling them for you as well. The generated classes are cached and the created
initializer is inserted in a class between your descendant and the Struct subclass
itself. If you want defaults, use a `Module#prepend` or `Module#include` solution,
or just call `super` with some keyword arguments set to their defaults.

## Contributing to ks
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2015 WeTransfer. See LICENSE.txt for
further details.
