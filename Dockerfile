FROM ubuntu:18.04

ENV PHP=7.2 \
    ADMINER=4.7.2 \
    SERVERNAME=dev-php.local \
    WORKDIR=/var/www/dev-php \
    DOCROOT=/var/www/dev-php/public \
    DEBIAN_FRONTEND=noninteractive \
    BUILD_PACKAGES=gnupg

COPY files/ /

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install --no-install-recommends $BUILD_PACKAGES && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C && \
    echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" >> /etc/apt/sources.list && \
    apt-get -y install --no-install-recommends software-properties-common && \ 
    add-apt-repository ppa:dhor/myway && \
    apt-get update && \
    apt-get -y install --no-install-recommends curl nano ca-certificates unzip git software-properties-common pkg-config \
    libvips42 libvips-tools libvips-dev \
    apache2 \
    php${PHP} php${PHP}-dev php-pear \
    libapache2-mod-php${PHP} \
    php-redis \
    php-memcached \
    php-imagick \
    jpegoptim \
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
    echo "extension=vips.so" > /etc/php/${PHP}/mods-available/vips.ini && \
    ln -sf /etc/php/${PHP}/mods-available/vips.ini /etc/php/${PHP}/cli/conf.d/20-vips.ini && \
    ln -sf /etc/php/${PHP}/mods-available/vips.ini /etc/php/${PHP}/apache2/conf.d/20-vips.ini && \
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
    pecl install vips && \
    apt-get -y purge $BUILD_PACKAGES libvips-dev php${PHP}-dev php-pear pkg-config software-properties-common && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 80/tcp \
       443/tcp

CMD ["/apache-foreground.sh"]
