#!/bin/bash
export PLUGIN_NAME=$(sed -n -e "s/# name: \([^ ]*\)\s*/\1/p" plugin.rb)
echo "PLUGIN_NAME=$PLUGIN_NAME"
chmod -R 777 . # This is necessary if your plugin installs gems
