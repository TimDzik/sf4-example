# sf-flex-demo

[![Travis CI](https://img.shields.io/travis/brpaz/sf4-example.svg?style=flat-square)](https://travis-ci.org/brpaz/sf4-example)

> Symfony Flex base application

## Requirements

  * PHP 7.1.3
  * [Composer](https://getcomposer.org/download/) 
  * and the [usual Symfony application requirements][https://symfony.com/doc/current/reference/requirements.html].
  * Instead, you can use [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/)

## Installation

The recommented way to run this application is with [Docker Compose](https://docs.docker.com/compose/). That way you dont have to install any project dependency on your host machine.

We also provide a simple wrapper script "appCtl" in the root folder of the project which provides am abstraction to some most used commands.

### With Docker

The docker-compose file provided in this project, provides a good set of building blocks for PHP applications. It includes an Nginx, PHP-FPM, MySQL and Memcached images by default as well as some commented out code for other that you might need like Redis and ElasticSearch.

To start the application with docker-compose just run:

```
sudo chmod +x appCtl
./appCtl up
```

or directly

```
docker-compose up
```

**Note:** If you want to use XDebug, its recommended to use the appCtl dommand or export the "DOCKER_REMOTE_HOST" with your host IP address. More info on [Running XDebug with Docker and PHPStorm]

The application should start and be availble on "localhost:8080" by default. You can override it using the "PORT" environment variable.

Example: ```PORT=9000 appCtl up```

The provided Dockerfile, includes some of most used extensions like Intl, Mcrypt, Imagick, Redis and Memcached.

### Locally

If you prefer to run the application directly in your machine, just run;

```
composer install
```

```
composer start
```

This should start the built-in web server in Port 8080.

Check composer scripts section for more useful commands like ```composer test``` or ```composer lint```


### Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)


### Tests

```
composer test or ./appCtl test (with docker)
```

#### Running XDebug with Docker and PHPStorm

"xdebug" is installed and configured in the Docker image. It automatically disable itself when starting the container with APP_ENV=prod.

To be able to accept connections from XDebug you must configure your IDE.
In PHPStorm, make sure you configure the Remote Server and User Path mappings. [This](https://medium.com/@pablofmorales/xdebug-with-docker-and-phpstorm-786da0d0fad2) tutorial, can guide you in That.

**Note:**  When configuring "User Mappings", the application is located in "/srv/app" inside the container and XDebug configured to connect to port "9001" on the host machine.

### Performance monitoring with Blackfire.

A "blackfire" container is provided out of the box, in Docker Compose file. To be able to use it, you have to set "BLACKFIRE_SERVER_ID",
"BLACKFIRE_SERVER_TOKEN" in the ".env file.
You can get this credentials in your [blackfire account page](https://blackfire.io/account).


## Symfony resources

* [Offical Documentation](https://symfony.com/doc/current/index.html)
* [symfony-demo](https://github.com/symfony/demo) - Official Symfony Demo Application.
* [KnpUniversity](https://knpuniversity.com/) - Simply the Best PHP 
& Symfony Tutorials.
* [Slack channel](https://symfony-devs.slack.com) - Symfony slack channel
