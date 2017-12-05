FROM composer:1.5
FROM php:7.1-fpm-alpine

ARG UID=1000
ARG GID=1000

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER 1

ENV APCU_VERSION 5.1.8

# Application environemnt variables
ENV APP_ENV prod
ENV APP_DEBUG 0

# Create an unpriviledged user for our application and add it to the default www-data group.
# This will make sure that permissions work and that folders will have the correct owner and group when mounting
# as volume in development.
RUN addgroup app -g ${GID} && adduser -u ${UID} -D -G app app && addgroup app www-data

RUN apk add --no-cache --virtual .persistent-deps \
    git \
    icu-libs \
    zlib \
    libmemcached

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    icu-dev \
    zlib-dev \
    libmemcached-dev \
    cyrus-sasl-dev \
    && docker-php-ext-install \
    intl \
    zip \
    pdo_mysql \
    && pecl install \
    apcu-${APCU_VERSION} \
    xdebug \
    memcached \
    redis \
    phpdbg \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
    && docker-php-ext-enable memcached \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable --ini-name 05-opcache.ini opcache \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.remote_enable=on" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=on" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
    #&& echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=0" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
    && apk del .build-deps

# Installs blackfire
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/alpine/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini

COPY docker/app/php.ini $PHP_INI_DIR/php.ini
COPY docker/app/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY --from=0 /usr/bin/composer /usr/bin/composer

COPY docker/app/docker-entrypoint.sh /usr/local/bin/docker-app-entrypoint
RUN chmod +x /usr/local/bin/docker-app-entrypoint

WORKDIR /srv/app

# Use prestissimo to speed up builds
RUN composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-progress --no-suggest --optimize-autoloader --classmap-authoritative  --no-interaction

COPY . .

RUN mkdir -p var/cache var/logs var/sessions \
    && composer install --prefer-dist --no-progress --no-suggest --classmap-authoritative --optimize-autoloader --apcu-autoloader --no-interaction \
    && composer clear-cache \
    && chown -R app:app var

ENTRYPOINT ["docker-app-entrypoint"]
CMD ["php-fpm"]
