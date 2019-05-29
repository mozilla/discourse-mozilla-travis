# discourse-mozilla-travis

*Inspired by https://meta.discourse.org/t/setting-up-plugin-continuous-integration-tests-on-travis-ci/59612*

This repo holds the scripts we use across our [Discourse plugins](https://github.com/search?q=org%3Amozilla+topic%3Adiscourse-plugin) to run tests in Travis CI and check coverage on Coveralls.

Incorporating these scripts into a plugin is a multi-step process:

## Set up Travis CI

Enable [Travis CI](https://travis-ci.org/) for the repo of the plugin in question.

[`.travis.yml`](.travis.yml) is a travis config file which runs these scripts, it should be placed in the root of a plugin repo.

A [Travis cron job](https://docs.travis-ci.com/user/cron-jobs/) should be set up to run every day to test the plugin against the latest upstream code.

## Set up Coveralls

Enable [Coveralls](https://coveralls.io/) for the repo of the plugin in question.

This code must be run at the **very top** of every spec:

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

When run locally it'll also place output in the `coverage/` folder, so this should be added to the repo's `.gitignore`.

## Checklist

* Enable Travis CI
* Include [`.travis.yml`](.travis.yml)
* Set up Travis cron job
* Enable Coveralls
* Include [`plugin_helper.rb`](plugin_helper.rb)
* Move testable code out of `plugin.rb`
* Add `coverage` to `.gitignore`
* Add build status and coverage status badges to `README.md`

## Bug reports

Bug reports should be filed [by following the process described here](https://discourse.mozilla.org/t/where-do-i-file-bug-reports-about-discourse/32078).

## Licence

[GPL-2.0](LICENSE)

[`.travis.yml`](.travis.yml) and [`plugin_helper.rb`](plugin_helper.rb) also licensed under [MPL-2.0](https://www.mozilla.org/en-US/MPL/2.0/)
