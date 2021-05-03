FROM php:8-cli-buster
MAINTAINER R. Hessing

# Set default timezone to UTC
ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y \
        git \
        gettext \
        libaspell-dev \
        libbz2-dev \
        libgmp-dev \
        libicu-dev \
        libmcrypt-dev \
        libunistring-dev \
        libuv1-dev \
        libzip-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libmagickwand-dev \
        libmemcached-dev \
        libtidy-dev \
        default-mysql-client \
        openssh-server \
        tini \
        unzip \
        zip \
        zlib1g-dev \
        --no-install-recommends
        
RUN docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable gd \
    && docker-php-ext-configure bcmath \
    && docker-php-ext-install -j$(nproc) bcmath \
    && docker-php-ext-enable bcmath \
    && docker-php-ext-configure bz2 \
    && docker-php-ext-install -j$(nproc) bz2 \
    && docker-php-ext-enable bz2 \
    && docker-php-ext-configure exif \
    && docker-php-ext-install -j$(nproc) exif \
    && docker-php-ext-enable exif \
    && docker-php-ext-configure gettext \
    && docker-php-ext-install -j$(nproc) gettext \
    && docker-php-ext-enable gettext \
    && docker-php-ext-configure gmp \
    && docker-php-ext-install -j$(nproc) gmp \
    && docker-php-ext-enable gmp \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-enable intl \
    && docker-php-ext-configure mcrypt \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-configure pdo_mysql \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable pdo_mysql \
    && docker-php-ext-configure mysqli \
    && docker-php-ext-install -j$(nproc) mysqli \
    && docker-php-ext-enable mysqli \
    && docker-php-ext-configure pspell \
    && docker-php-ext-install -j$(nproc) pspell \
    && docker-php-ext-enable pspell \
    && docker-php-ext-configure shmop \
    && docker-php-ext-install -j$(nproc) shmop \
    && docker-php-ext-enable shmop \
    && docker-php-ext-configure tidy \
    && docker-php-ext-install -j$(nproc) tidy \
    && docker-php-ext-enable tidy \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-enable zip \
    && pecl channel-update pecl.php.net \
    && pecl install imagick \
    && pecl install mcrypt \
    && pecl install memcached \
    && pecl install redis \
    && pecl install xdebug \
    && docker-php-ext-enable imagick \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-enable memcached \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable xdebug \
    && composer self-update --2 \
    && apt-get erase g++ make \
    && rm -rf /tmp/* \
    && rm /var/cache/* \
    # Always refresh keys
    && rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && printf '[PHP]\ndate.timezone = "__TIMEZONE__"\n' > /usr/local/etc/php/conf.d/tzone.ini \
    && echo "zend_extension = $(find /usr/local/lib/php/extensions/ -name xdebug.so)" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "error_reporting = __ERROR_REPORTING__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "display_startup_errors = __DISPLAY_STARTUP_ERRORS__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "display_errors = __DISPLAY_ERRORS__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.file_link_format = __FILE_LINK_FORMAT__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey = \"__IDEKEY__\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port = __REMOTE_PORT__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_enable = __REMOTE_ENABLE__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart = __REMOTE_AUTOSTART__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_host = __REMOTE_HOST__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

COPY docker-entrypoint.sh /usr/local/bin/

RUN mkdir -p /var/www \
    && chmod 755 /usr/local/bin/docker-entrypoint.sh \
    && addgroup -g 1000 php \
    && adduser -D -u 1000 -s /bin/bash -G php php \
    && passwd -u php \
    && mkdir -p /home/php/.ssh \
    && chown php:php /home/php/.ssh \
    && chmod 0700 /home/php/.ssh

EXPOSE 22
ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/usr/local/bin/docker-entrypoint.sh"]
