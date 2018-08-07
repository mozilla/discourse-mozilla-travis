# discourse-mozilla-travis

*Inspired by https://meta.discourse.org/t/setting-up-plugin-continuous-integration-tests-on-travis-ci/59612*

This repo holds the scripts we use across our [Discourse plugins](https://github.com/search?q=org%3Amozilla+topic%3Adiscourse-plugin) to run tests and check code coverage in Travis CI.

[`.travis.yml`](.travis.yml) is a travis config file which runs these scripts, it should be placed in the root of a plugin repo.

To check code coverage in plugins, this code must be run at the **very top** of every spec:

```ruby
if ENV["COVERALLS"] || ENV["SIMPLECOV"]
  require "simplecov"

  if ENV["COVERALLS"]
    require "coveralls"
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  end

  SimpleCov.start do
    root File.expand_path("../..", __FILE__)
    add_filter "spec/"
    add_filter "db/migrate"
    add_filter "gems/"
  end
end

require "rails_helper"
```

For inconvenience [`plugin_helper.rb`](plugin_helper.rb) contains this code, and if placed in the plugin's `spec/` folder, it can be included in specs with:

```ruby
require_relative "plugin_helper"
```

(which must also go at the **very top** of every spec)

This won't test coverage of code in a plugin's `plugin.rb` file, so all testable code should be moved into a separate file which can be included with `require_relative`.
