#!/bin/bash

# exit when any command fails
set -e

for php in 7.0 7.1 7.2 7.4 7.3 8.0 8.1
  do 
    echo "### Switching PHP Version in Dockerfile to $php"
    sed -i '' -E "s/ PHP=[[:digit:]]\.[[:digit:]] / PHP=$php /" Dockerfile
    echo "### Building local image for PHP $php"
    docker build -t scalecommerce/dev-php:$php .
    #local_version=$(cat version)
    today=$(date '+%Y-%m-%d')
    php_version=$(docker run --rm scalecommerce/dev-php:$php php -r "echo PHP_MAJOR_VERSION, '.', PHP_MINOR_VERSION, '.', PHP_RELEASE_VERSION;")
    echo "### Creating new tag $php_version-$today"
    #git commit -am "build PHP $php_version"
    #git tag "$php_version-$local_version"
    #echo "### Triggering build for tag $php_version-v$local_version on Docker Hub"
    #git push origin "$php_version-$local_version"
    docker image tag scalecommerce/dev-php:$php scalecommerce/dev-php:$php_version-$today
    docker image push scalecommerce/dev-php:$php_version-$today
  done
