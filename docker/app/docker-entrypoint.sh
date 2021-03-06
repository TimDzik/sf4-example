#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'bin/console' ]; then
    # The first time volumes are mounted, the project needs to be recreated
    if [ ! -f composer.json ]; then
        composer create-project "symfony/skeleton" tmp --stability=$STABILITY --prefer-dist --no-progress --no-interaction
        cp -Rp tmp/. .
        rm -Rf tmp/
    elif [ "$APP_ENV" != 'prod' ]; then
        # Always try to reinstall deps when not in prod
        composer install --prefer-dist --no-progress --no-suggest --no-interaction
    fi

    if [ "$APP_ENV" = 'prod' ]; then
            echo "Disabling xdebug in prod"
            rm -rf /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    fi

	# Permissions hack because setfacl does not work on Mac and Windows
	chown -R app:app var
fi

exec docker-php-entrypoint "$@"
