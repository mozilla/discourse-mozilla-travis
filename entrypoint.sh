#!/bin/bash
echo "travis_fold:start:discourse_setup"
  echo "Running discourse setup..."

  export RAILS_ENV=test
  export COVERALLS=1

  git pull || exit 1
  git checkout origin/tests-passed || exit 1

  echo "gem 'simplecov'" >> Gemfile
  echo "gem 'coveralls'" >> Gemfile

  bundle || exit 1

  echo "Cleaning up old test tmp data in tmp/test_data"
  rm -fr tmp/test_data && mkdir -p tmp/test_data/redis && mkdir tmp/test_data/pg

  echo "Starting background redis"
  redis-server --dir tmp/test_data/redis &

  echo "Starting postgres"
  /usr/lib/postgresql/10/bin/initdb -D tmp/test_data/pg
  echo fsync = off >> tmp/test_data/pg/postgresql.conf
  echo full_page_writes = off >> tmp/test_data/pg/postgresql.conf
  echo shared_buffers = 500MB >> tmp/test_data/pg/postgresql.conf
  /usr/lib/postgresql/10/bin/postmaster -D tmp/test_data/pg &
  sleep 5

  echo "Creating database"
  bundle exec rake db:create || exit 1

  echo "Running migrations"
  bundle exec rake db:migrate || exit 1

  echo "End of discourse setup"
echo "travis_fold:end:discourse_setup"

bundle exec rake plugin:spec[$PLUGIN_NAME]
bundle exec rake plugin:qunit[$PLUGIN_NAME]
