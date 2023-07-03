FROM ubuntu:20.04

ENV PHP=8.2 \
    ADMINER=4.8.1 \
    SERVERNAME=dev-php.local \
    WORKDIR=/var/www/dev-php \
    DOCROOT=/var/www/dev-php/public \
    DEBIAN_FRONTEND=noninteractive \
    BUILD_PACKAGES=software-properties-common \
    TINI_VERSION=v0.19.0

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

COPY files/ /

RUN apt-get update && \
    apt-get -y install --no-install-recommends $BUILD_PACKAGES && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install --no-install-recommends curl nano ca-certificates unzip git \
    libvips42 libvips-tools \
    apache2 \
    php${PHP} \
    libapache2-mod-php${PHP} \
    php${PHP}-redis \
    php${PHP}-memcached \
    php${PHP}-imagick \
    jpegoptim \
    php${PHP}-amqp \
    php${PHP}-apcu \
    php${PHP}-gmp \
    php${PHP}-bcmath \
    php${PHP}-bz2 \
    php${PHP}-cli \
    php${PHP}-curl \
    php${PHP}-gd \
    php${PHP}-intl \
    php${PHP}-mbstring \
    php${PHP}-mysql \
    php${PHP}-opcache \
    php${PHP}-readline \
    php${PHP}-soap \
    php${PHP}-sqlite3 \
    php${PHP}-xml \
    php${PHP}-vips \
    php${PHP}-swoole \
    php${PHP}-rdkafka \
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
