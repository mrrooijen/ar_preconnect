## ActiveRecord Preconnect

[![Gem Version](https://badge.fury.io/rb/ar_preconnect.svg)](https://badge.fury.io/rb/ar_preconnect)

This library adds the `preconnect!` method to `ActiveRecord::ConnectionAdapters::ConnectionPool`. Use this when you want all of your connections in your connection pool to eagerly connect to the database, rather than lazily.

### Why

When using [Postgres] on [Heroku] with [PGBouncer] you can run into situations where your [process will hang indefinitely]. This issue occurs when using ActiveRecord, Sequel and potentially other database mappers.

The solution in Sequel is to set the `preconnect` option to `true`. This option tells Sequel to open all database connection eagerly, rather than lazily, and avoids potential deadlocks. I couldn't find an equivalent option in ActiveRecord so I wrote this small library to provide a method to do so.


### Installation

Add this line to your application's Gemfile:

```rb
gem "ar_preconnect"
```

### Usage

With [Sidekiq]:

```rb
# ./config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  ActiveRecord::Base.connection.pool.preconnect!
end
```

With [Passenger] in cluster-mode.

```rb
# ./config/initializers/passenger.rb
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      ActiveRecord::Base.establish_connection
      ActiveRecord::Base.connection.pool.preconnect!
    end
  end
end
```

With [Unicorn] in cluster-mode.

```rb
# ./config/initializers/unicorn.rb
before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
  ActiveRecord::Base.connection.pool.preconnect!
end
```

With [Puma] in cluster-mode.

```rb
# ./config/initializers/puma.rb
on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.connection.pool.preconnect!
  end
end
```

With [Clockwork]:

```rb
# ./clock.rb
require "clockwork"
require_relative "config/boot"
require_relative "config/environment"

ActiveRecord::Base.connection.pool.preconnect!

module Clockwork
  every(1.minute, "do something") do
    MyWorker.perform_async
  end
end
```

### Verify 

Verify that this works:

```rb
pool = ActiveRecord::Base.connection.pool

puts "#{pool.connections.count} connections established."
pool.preconnect!
puts "#{pool.connections.count} connections established."
```


### Author / License

Released under the [MIT License] by [Michael van Rooijen].

[Postgres]: http://www.postgresql.org
[Heroku]: https://www.heroku.com
[PGBouncer]: https://pgbouncer.github.io
[Sidekiq]: http://sidekiq.org
[Passenger]: https://www.phusionpassenger.com
[Unicorn]: http://unicorn.bogomips.org
[Puma]: http://puma.io
[Clockwork]: https://github.com/tomykaira/clockwork
[process will hang indefinitely]: https://github.com/heroku/heroku-buildpack-pgbouncer/issues/29
[MIT License]: https://github.com/meskyanichi/ar_preconnect/blob/master/LICENSE
[Michael van Rooijen]: http://michael.vanrooijen.io
