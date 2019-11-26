# PHP Development Environment

This image is for php development. It provides:

* Apache2
* PHP (see Tags for available versions)
* Composer
* Adminer

## Docroot & Tools
The default docroot is `/var/www/dev-php` but you can override this via the environment variable `DOCRROT`. Adminer is available in your browser at the url `/_adminer`, phpinfo() is available at `/_phpinfo`.

## Usage
On Mac OS X run `docker run -tid --name php-dev  -v $(pwd):/var/www/dev-php -p 127.0.0.1:80:80 scalecommerce/dev-php:<version>`. Then point your browser to http://localhost/ to access the site.

## Docker-Compose Example
Here's a simply example using this image with docker-compose. Put this in your `docker-compose.yml`:
```
version: "3.5"
services:

  php:
    working_dir: /var/www/dev-php
    image: scalecommerce/dev-php:7.3.8
    volumes:
      - .:/var/www/dev-php:cached
    environment:
      APP_DEBUG: "true"
    ports:
      - 127.0.0.1:80:80
    links:
      - mysql
    depends_on:
      - mysql

  mysql:
    image: percona:5.7
    environment:
      MYSQL_ROOT_PASSWORD: toor
      MYSQL_DATABASE: db
      MYSQL_USER: dev
      MYSQL_PASSWORD: dev
    ports:
      - 127.0.0.1:3306:3306
```
and then start up the stack with `docker-compose up -d`.

## PHP modules
Currently the following php modules are installed. Open a PR if you need more.
```
[PHP Modules]
amqp
apcu
bcmath
bz2
calendar
Core
ctype
curl
date
dom
exif
fileinfo
filter
ftp
gd
gettext
gmp
hash
iconv
igbinary
imagick
intl
json
libxml
mbstring
memcached
msgpack
mysqli
mysqlnd
openssl
pcntl
pcre
PDO
pdo_mysql
pdo_sqlite
Phar
posix
readline
redis
Reflection
session
shmop
SimpleXML
soap
sockets
sodium
SPL
sqlite3
standard
sysvmsg
sysvsem
sysvshm
tokenizer
wddx
xml
xmlreader
xmlwriter
xsl
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
```

