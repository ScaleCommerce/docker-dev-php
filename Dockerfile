FROM ubuntu:18.04

ENV PHP=7.3 \
    ADMINER=4.7.2 \
    SERVERNAME=dev-php.local \
    WORKDIR=/var/www/dev-php \
    DOCROOT=/var/www/dev-php/public \
    DEBIAN_FRONTEND=noninteractive \
    BUILD_PACKAGES=gnupg

COPY files/ /

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install $BUILD_PACKAGES && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C && \
    echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" >> /etc/apt/sources.list && \
    apt-get -y install software-properties-common && \ 
    add-apt-repository ppa:dhor/myway && \
    apt-get update && \
    apt-get -y install --no-install-recommends curl nano ca-certificates unzip git software-properties-common \
    libvips42 libvips-tools \
    apache2 \
    php${PHP} \
    libapache2-mod-php${PHP} \
    php-redis \
    php-memcached \
    php-imagick \
    php-amqp \
    php-apcu \
    php${PHP}-gmp \
    php${PHP}-bcmath \
    php${PHP}-bz2 \
    php${PHP}-cli \
    php${PHP}-curl \
    php${PHP}-gd \
    php${PHP}-intl \
    php${PHP}-json \
    php${PHP}-mbstring \
    php${PHP}-mysql \
    php${PHP}-opcache \
    php${PHP}-readline \
    php${PHP}-soap \
    php${PHP}-sqlite3 \
    php${PHP}-xml \
    php${PHP}-zip && \
    a2enmod rewrite && \
    rm -rf /etc/apache2/sites-enabled/000-default.conf /var/www/html && \
    echo 'ServerName $SERVERNAME' >>/etc/apache2/apache2.conf && \
    mv /dev-php.conf /etc/apache2/sites-enabled/ && \
    mkdir -p $DOCROOT && chown www-data:www-data $DOCROOT && \
    mkdir -p $WORKDIR && chown www-data:www-data $WORKDIR && \
    mkdir -p /var/www/adminer && \
    curl -sSL https://github.com/vrana/adminer/releases/download/v${ADMINER}/adminer-${ADMINER}-mysql-en.php > /var/www/adminer/index.php && \
    mkdir -p /var/www/phpinfo && mv /info.php /var/www/phpinfo/index.php && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    apt-get -y purge $BUILD_PACKAGES && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 80/tcp \
       443/tcp

CMD ["/apache-foreground.sh"]
