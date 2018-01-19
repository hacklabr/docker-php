FROM php:5.6-apache
MAINTAINER Hacklab <contato@hacklab.com.br>

RUN a2enmod rewrite expires \
    && apt-get update \
    && apt-get install -y libpng12-dev libjpeg-dev libmemcached-dev libmcrypt-dev unzip \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install calendar gd mbstring mcrypt mysqli opcache zip \
    && printf "yes\n" | pecl install memcached-2.2.0 \
    && printf "yes\n" | pecl install xdebug \
    && printf "no\n"  | pecl install apcu-4.0.11 \
    && echo 'extension=memcached.so' > /usr/local/etc/php/conf.d/pecl-memcached.ini \
    && echo 'extension=apcu.so' > /usr/local/etc/php/conf.d/pecl-apcu.ini \
    && curl -s -o /usr/local/bin/composer https://getcomposer.org/composer.phar \
    && chmod 555 /usr/local/bin/composer \
    && apt-get purge -y libpng-dev libjpeg-dev libmemcached-dev libmcrypt-dev \
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
