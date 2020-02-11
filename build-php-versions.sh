#!/bin/bash

# exit when any command fails
set -e

for php in 5.6 7.0 7.1 7.2 7.4 7.3
  do 
    echo "### Switching PHP Version in Dockerfile to $php"
    sed -i '' -E "s/ PHP=[[:digit:]]\.[[:digit:]] / PHP=$php /" Dockerfile
    echo "### Building local image for PHP $php"
    docker build -t scalecommerce-dev-php:local .
    local_version=$(cat version)
    php_version=$(docker run --rm scalecommerce-dev-php:local php -r "echo PHP_MAJOR_VERSION, '.', PHP_MINOR_VERSION, '.', PHP_RELEASE_VERSION;")
    echo "### Creating new tag $php_version-v$local_version"
    git commit -am "build PHP $php_version"
    git tag "$php_version-v$local_version"
    echo "### Triggering build for tag $php_version-v$local_version on Docker Hub"
    git push origin "$php_version-v$local_version"
  done
