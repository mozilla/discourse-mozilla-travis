#!/bin/bash -x

docker run \
  -t \
  -e CI=$CI \
  -e TRAVIS=$TRAVIS \
  -e TRAVIS_JOB_ID=$TRAVIS_JOB_ID \
  -e TRAVIS_PULL_REQUEST=$TRAVIS_PULL_REQUEST \
  -e PLUGIN_NAME=$PLUGIN_NAME \
  -v $(pwd):/var/www/discourse/plugins/$PLUGIN_NAME \
  --entrypoint /var/www/discourse/plugins/$PLUGIN_NAME/discourse-mozilla-travis/entrypoint.sh \
  --user discourse \
  discourse/discourse_test:release
