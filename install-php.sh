#!/bin/bash
for PHP_MAJOR in $PHP_VERSIONS
do
    echo "libphp${PHP_MAJOR}-embed" >> /php-packages.apt
    cat /php-modules.conf |xargs -I{} echo "php${PHP_MAJOR}-{}" >> /php-packages.apt
done

# there is no geoip module for php 8.0 yet
sed -i '/php8.0-geoip/d' /php-packages.apt

# json is now built in php 8.0
sed -i '/php8.0-json/d' /php-packages.apt

# there is no vips module for php 5.6
sed -i '/php5.6-vips/d' /php-packages.apt

apt install -y --no-install-recommends $(cat /php-packages.apt)

# create symlink of php module so unit can switch between versions
# https://github.com/nginx/unit/issues/284
for PHP_MAJOR in $PHP_VERSIONS
do
    ln -s /usr/lib/libphp${PHP_MAJOR}.so /usr/lib/php/${PHP_MAJOR}/sapi/libphp${PHP_MAJOR:0:1}.so
done
