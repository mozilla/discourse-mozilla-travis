#!/bin/bash
echo "travis_fold:start:discourse_setup"
  echo "Running discourse setup..."

  export RAILS_ENV=test
  export COVERALLS=1

  git fetch origin tests-passed -q || exit 1
  git reset --hard origin/tests-passed -q || exit 1

  echo "gem 'coveralls', '>=0.8'" >> Gemfile

  bundle update simplecov > /dev/null || exit 1
  bundle > /dev/null || exit 1

  echo "Removing other plugins"
  find plugins/ -mindepth 1 -maxdepth 1 ! -name $PLUGIN_NAME ! -path "plugins/discourse-narrative-bot" -type d -exec rm -rf {} +

  echo "Cleaning up old test tmp data in tmp/test_data"
  rm -fr tmp/test_data && mkdir -p tmp/test_data/redis && mkdir tmp/test_data/pg

  echo "Starting background redis"
  redis-server --dir tmp/test_data/redis > /dev/null &

  echo "Starting postgres"
  /usr/lib/postgresql/10/bin/initdb -D tmp/test_data/pg > /dev/null
  echo fsync = off >> tmp/test_data/pg/postgresql.conf
  echo full_page_writes = off >> tmp/test_data/pg/postgresql.conf
  echo shared_buffers = 500MB >> tmp/test_data/pg/postgresql.conf
  /usr/lib/postgresql/10/bin/postmaster -D tmp/test_data/pg > /dev/null &
  sleep 5

  echo "Creating database"
  bundle exec rake db:create > /dev/null || exit 1

  echo "Running migrations"
  bundle exec rake db:migrate > /dev/null || exit 1

  echo "Running plugin migrations"
  LOAD_PLUGINS=1 bundle exec rake db:migrate > /dev/null || exit 1

  echo "End of discourse setup"
echo "travis_fold:end:discourse_setup"

bundle exec rake plugin:spec[$PLUGIN_NAME] || exit 1
if [ -d "/var/www/discourse/plugins/$PLUGIN_NAME/test" ]; then
  bundle exec rake plugin:qunit[$PLUGIN_NAME] || exit 1
fi
