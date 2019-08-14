#!/bin/bash
mkdir -p /var/run/apache2
if [ ! -d "$DOCROOT" ]; then
  echo "creating docroot $DOCROOT"
  mkdir -p "$DOCROOT"
  chown www-data:www-data $DOCROOT
fi
source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND