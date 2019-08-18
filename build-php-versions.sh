#!/bin/bash

# exit when any command fails
set -e

for php in 5.6 7.0 7.1 7.2 7.3
  do 
    sed -i -E "s/ PHP=[[:digit:]]\.[[:digit:]] / PHP=$php /" Dockerfile
    docker build -t scalecommerce-dev-php:local .
    local_version=$(cat version)
    php_version=$(docker run --rm scalecommerce-dev-php:local php -r "echo PHP_MAJOR_VERSION, '.', PHP_MINOR_VERSION, '.', PHP_RELEASE_VERSION;")
    git commit -am "build PHP $php_version"
    git tag "$php_version-v$local_version"
    git push "$php_version-v$local_version"
  done
