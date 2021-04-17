FROM ubuntu:20.04 as BUILDER

ENV DEBIAN_FRONTEND=noninteractive \
    PHP_VERSIONS="5.6 7.0 7.1 7.2 7.3 7.4 8.0"
RUN set -ex \
    && apt-get update \
    && mkdir -p /usr/lib/unit/modules /usr/lib/unit/debug-modules \
    && apt-get install --no-install-recommends --no-install-suggests -y ca-certificates gnupg mercurial build-essential libssl-dev libpcre2-dev apt-utils \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main" >> /etc/apt/sources.list \
    && apt-get update \
    && for PHP_MAJOR in $PHP_VERSIONS ; \
    do \
        apt-get -y install php${PHP_MAJOR}-dev libphp${PHP_MAJOR}-embed ; \
    done \
    && hg clone https://hg.nginx.org/unit \
    && cd unit \
    && hg up 1.23.0 \
    && NCPU="$(getconf _NPROCESSORS_ONLN)" \
    && DEB_HOST_MULTIARCH="$(dpkg-architecture -q DEB_HOST_MULTIARCH)" \
    && CC_OPT="$(DEB_BUILD_MAINT_OPTIONS="hardening=+all,-pie" DEB_CFLAGS_MAINT_APPEND="-Wp,-D_FORTIFY_SOURCE=2 -fPIC" dpkg-buildflags --get CFLAGS)" \
    && LD_OPT="$(DEB_BUILD_MAINT_OPTIONS="hardening=+all,-pie" DEB_LDFLAGS_MAINT_APPEND="-Wl,--as-needed -pie" dpkg-buildflags --get LDFLAGS)" \
    && CONFIGURE_ARGS="--prefix=/usr \
                --state=/var/lib/unit \
                --control=unix:/var/run/control.unit.sock \
                --pid=/var/run/unit.pid \
                --log=/var/log/unit.log \
                --tmp=/var/tmp \
                --user=unit \
                --group=unit \
                --openssl \
                --libdir=/usr/lib/$DEB_HOST_MULTIARCH" \
    && ./configure $CONFIGURE_ARGS --cc-opt="$CC_OPT" --ld-opt="$LD_OPT" --modules=/usr/lib/unit/debug-modules --debug \
    && make -j $NCPU unitd \
    && install -pm755 build/unitd /usr/sbin/unitd-debug \
    && make clean \
    && ./configure $CONFIGURE_ARGS --cc-opt="$CC_OPT" --ld-opt="$LD_OPT" --modules=/usr/lib/unit/modules \
    && make -j $NCPU unitd \
    && install -pm755 build/unitd /usr/sbin/unitd \
    && make clean \
    && ./configure $CONFIGURE_ARGS --cc-opt="$CC_OPT" --modules=/usr/lib/unit/debug-modules --debug \
    && for PHP_MAJOR in $PHP_VERSIONS ; \
    do \
         ./configure php --module=php${PHP_MAJOR} --config=/usr/bin/php-config${PHP_MAJOR} --lib-path=/usr/lib/php/${PHP_MAJOR}/sapi ; \
        make -j $NCPU php${PHP_MAJOR}-install ; \
    done \
    && make clean \
    && ./configure $CONFIGURE_ARGS --cc-opt="$CC_OPT" --modules=/usr/lib/unit/modules \
    && for PHP_MAJOR in $PHP_VERSIONS ; \
    do \
         ./configure php --module=php${PHP_MAJOR} --config=/usr/bin/php-config${PHP_MAJOR} --lib-path=/usr/lib/php/${PHP_MAJOR}/sapi ; \
        make -j $NCPU php${PHP_MAJOR}-install ; \
    done \
    && ldd /usr/sbin/unitd | awk '/=>/{print $(NF-1)}' | while read n; do dpkg-query -S $n; done | sed 's/^\([^:]\+\):.*$/\1/' | sort | uniq > /requirements.apt

FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive \
    PHP_VERSIONS="5.6 7.0 7.1 7.2 7.3 7.4 8.0" \
    ADMINER=4.8.0 \
    SERVERNAME=dev-php.local \
    WORKDIR=/var/www/dev-php \
    DOCROOT=/var/www/dev-php/public
COPY docker-entrypoint.sh /usr/local/bin/
COPY php-modules.conf /php-modules.conf
COPY info.php /info.php
COPY install-php.sh /install-php.sh
COPY --from=BUILDER /usr/sbin/unitd /usr/sbin/unitd
COPY --from=BUILDER /usr/sbin/unitd-debug /usr/sbin/unitd-debug
COPY --from=BUILDER /usr/lib/unit/ /usr/lib/unit/
COPY --from=BUILDER /requirements.apt /requirements.apt
RUN ldconfig
RUN set -x \
    && mkdir -p /var/lib/unit/ \
    && mkdir /docker-entrypoint.d/ \
    && addgroup --system unit \
    && adduser \
         --system \
         --disabled-login \
         --ingroup unit \
         --no-create-home \
         --home /nonexistent \
         --gecos "unit user" \
         --shell /bin/false \
         unit \
    && apt update \
    && apt upgrade -y \
    && apt --no-install-recommends --no-install-suggests -y install gnupg nano bash curl ca-certificates jpegoptim libvips42 libvips-tools git $(cat /requirements.apt) \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main" >> /etc/apt/sources.list \
    && apt update \
    && apt upgrade -y \
    && chmod +x /install-php.sh ; /install-php.sh \
    && mkdir -p /var/www/adminer \
    && curl -sSL https://github.com/vrana/adminer/releases/download/v${ADMINER}/adminer-${ADMINER}-mysql-en.php > /var/www/adminer/index.php \
    && mkdir -p /var/www/phpinfo && mv /info.php /var/www/phpinfo/index.php \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/* \
    && ln -sf /dev/stdout /var/log/unit.log

STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["unitd", "--no-daemon", "--control", "unix:/var/run/control.unit.sock"]
