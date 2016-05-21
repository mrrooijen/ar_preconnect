## ActiveRecord Preconnect

[![Gem Version](https://badge.fury.io/rb/ar_preconnect.svg)](https://badge.fury.io/rb/ar_preconnect)

This library adds the `preconnect!` method to `ActiveRecord::ConnectionAdapters::ConnectionPool`. Use this when you want all of your connections in your connection pool to eagerly connect to the database, rather than lazily.

### Why

When using [Postgres] on [Heroku] with [PGBouncer] you can run into situations where your [process will hang indefinitely]. This issue seems to occur when using ActiveRecord, Sequel and potentially other database mappers in a multi-threaded environment. 

The solution in Sequel is to set the `preconnect` option to `true`. This option tells Sequel to open all database connection eagerly, rather than lazily, and avoids potential deadlocks. I couldn't find an equivalent option in ActiveRecord so I wrote this small library to provide a method, enabling you to achieve the same behavior.


### Installation

Add the library to your Gemfile:

```rb
gem "ar_preconnect"
```


### Usage

Use the `preconnect!` method in any threaded environment. Here's a Sidekiq example:


```rb
Sidekiq.configure_server do |config|
  ActiveRecord::Base.connection.pool.preconnect!
end
```

Now, during the Sidekiq (server) configuration process, all of the connections in the ActiveRecord connection pool will establish a connection with the database, and will be ready before Sidekiq actually starts working.

You might also want to consider preconnecting with multi-threaded app servers such as [Passenger] and [Puma], or any other multi-threaded process.

Single-threaded app servers and worker libraries such as [Unicorn] and [Delayed Job] should use a connection pool of 1, won't need PGBouncer, and thus preconnection isn't necessary.


### Author / License

Released under the [MIT License] by [Michael van Rooijen].

[Postgres]: http://www.postgresql.org
[Heroku]: https://www.heroku.com
[PGBouncer]: https://pgbouncer.github.io
[Sidekiq]: http://sidekiq.org
[Passenger]: https://www.phusionpassenger.com
[Unicorn]: http://unicorn.bogomips.org
[Puma]: http://puma.io
[Delayed Job]: https://github.com/collectiveidea/delayed_job/
[process will hang indefinitely]: https://github.com/heroku/heroku-buildpack-pgbouncer/issues/29
[MIT License]: https://github.com/mrrooijen/ar_preconnect/blob/master/LICENSE
[Michael van Rooijen]: http://michael.vanrooijen.io
