FROM php:7.3-apache
MAINTAINER hacklab/ <contato@hacklab.com.br>

RUN a2enmod remoteip rewrite expires \
    && apt-get update \
    && apt-get install -y openssh-server libpng-dev libzip-dev libjpeg-dev libmemcached-dev libmcrypt-dev unzip nano vim less libzip-dev \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install calendar gd mbstring opcache zip 
RUN docker-php-ext-install mysqli
RUN printf "yes \n" | pecl install memcached\
    && printf "yes \n" | pecl install xdebug-beta\
    && printf "no \n"  | pecl install apcu-beta\
    && echo 'extension=memcached.so' > /usr/local/etc/php/conf.d/pecl-memcached.ini \
    && echo 'extension=apcu.so' > /usr/local/etc/php/conf.d/pecl-apcu.ini \
    && curl -s -o /usr/local/bin/composer https://getcomposer.org/composer.phar \
    && chmod 555 /usr/local/bin/composer \
    && apt-get purge -y libpng-dev libzip-dev libjpeg-dev libmemcached-dev libmcrypt-dev \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && { \
        echo "file_uploads = On"; \
        echo "upload_max_filesize = 2048M"; \
        echo "post_max_size = 2048M"; \
        echo "max_file_uploads = 20"; \
    } > /usr/local/etc/php/conf.d/docker-uploads.ini

COPY root/ /
EXPOSE 80 443 22

ENV USER_NAME=''
ENV USER_PASSWORD='hacklab'
ENV USER_FOLDER=''

RUN mkdir /var/run/sshd && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile
 

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
