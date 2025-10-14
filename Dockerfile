FROM php:5.6-apache-stretch
LABEL org.opencontainers.image.authors="Hacklab <contato@hacklab.com.br>"

# APT configurations need to be copied first to allow apt packages to be downloaded on Jessie
COPY root/etc/apt/ /etc/apt/

RUN a2enmod remoteip rewrite expires \
  && apt-get update \
  && apt-get install -y --allow-unauthenticated unzip nano vim less openssh-client git curl wget

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions gd calendar mbstring opcache zip mysqli memcached xdebug apcu pdo_mysql sockets mcrypt soap

RUN curl -s -o /usr/local/bin/composer https://getcomposer.org/download/2.2.21/composer.phar \
    && chmod 555 /usr/local/bin/composer \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && { \
        echo "file_uploads = On"; \
        echo "upload_max_filesize = 2048M"; \
        echo "post_max_size = 2048M"; \
        echo "max_file_uploads = 20"; \
    } > /usr/local/etc/php/conf.d/docker-uploads.ini

COPY root/ /

EXPOSE 80 443
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
