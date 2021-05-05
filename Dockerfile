FROM php:8-cli-buster
MAINTAINER R. Hessing

# Set default timezone to UTC
ENV TZ=Etc/UTC
ENV TINI_VERSION v0.19.0

# Install requirements for Tini and PHP extension builds
RUN apt-get update && apt-get install --no-install-recommends -y \
        default-mysql-client \
        dirmngr \
        git \
        libaspell-dev \
        libicu-dev \
        libmcrypt-dev \
        libunistring-dev \
        libuv1-dev \
        libzip-dev \
        libmagickwand-dev \
        libmemcached-dev \
        libtidy-dev \
        openssh-server \
        unzip \
        zip \
        zlib1g-dev \
        openssl \
        libssl-dev \
        libssh2-1-dev \
        libmagickwand-dev \
        imagemagick

# Install tiny
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
COPY docker-entrypoint.sh /usr/local/bin/

# Install composer
# Create default user 'php'
# Fix issue with k8s authorized_keys and configmaps
# Keep SSH connection open
RUN echo "" >> /etc/ssh/sshd_config \
    && echo "ClientAliveInterval 3" >> /etc/ssh/sshd_config \
    && chmod 755 /bin/tini \
    && chmod 755 /usr/local/bin/docker-entrypoint.sh \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && mkdir -p /var/www \
    && addgroup -gid 1000 php \
    && adduser -uid 1000 -gid 1000 --shell /bin/bash --disabled-password --gecos '' php \
    && passwd -u php \
    && mkdir -p /home/php/.ssh \
    && chown php:php /home/php/.ssh \
    && chmod 0700 /home/php/.ssh

RUN pecl channel-update pecl.php.net

# Configure, build and install additional PHP extensions
RUN docker-php-ext-configure pdo_mysql \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable pdo_mysql

RUN docker-php-ext-configure mysqli \
    && docker-php-ext-install -j$(nproc) mysqli \
    && docker-php-ext-enable mysqli

RUN docker-php-ext-configure shmop \
    && docker-php-ext-install -j$(nproc) shmop \
    && docker-php-ext-enable shmop

RUN docker-php-ext-configure tidy \
    && docker-php-ext-install -j$(nproc) tidy \
    && docker-php-ext-enable tidy

RUN docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-enable zip

RUN docker-php-ext-configure imagick \
    && docker-php-ext-install -j$(nproc) imagick \
    && docker-php-ext-enable imagick

RUN pecl install ssh2-1.3.1 \
    && docker-php-ext-enable ssh2

RUN pecl install quickhash \
    && docker-php-ext-enable quickhash

RUN pecl install lchash \
    && docker-php-ext-enable lchash

RUN pecl install trader \
    && docker-php-ext-enable trader

RUN pecl install pdflib \
    && docker-php-ext-enable pdflib

RUN pecl install date_time \
    && docker-php-ext-enable date_time

RUN pecl install hrtime \
    && docker-php-ext-enable hrtime

RUN pecl install timezonedb \
    && docker-php-ext-enable timezonedb

RUN pecl install xdiff \
    && docker-php-ext-enable xdiff

RUN pecl install gender \
    && docker-php-ext-enable gender

RUN pecl install xlswriter \
    && docker-php-ext-enable xlswriter

RUN pecl install pthreads \
    && docker-php-ext-enable pthreads

RUN pecl install parallel \
    && docker-php-ext-enable parallel

RUN pecl install mcrypt \
    && docker-php-ext-enable mcrypt

RUN pecl install memcached \
    && docker-php-ext-enable memcached

RUN pecl install redis \
    && docker-php-ext-enable redis

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug
    
# Cleanup
RUN rm -rf /tmp/* \
    && rm -rf /var/cache/apt/* \
    # Always refresh keys
    && rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

# Configure PHP
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && printf '[PHP]\ndate.timezone = "__TIMEZONE__"\n' > /usr/local/etc/php/conf.d/tzone.ini \
    && echo "zend_extension = $(find /usr/local/lib/php/extensions/ -name xdebug.so)" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "error_reporting = __ERROR_REPORTING__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "display_startup_errors = __DISPLAY_STARTUP_ERRORS__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "display_errors = __DISPLAY_ERRORS__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.mode = debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.file_link_format = __FILE_LINK_FORMAT__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey = \"__IDEKEY__\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port = __REMOTE_PORT__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request = __REMOTE_AUTOSTART__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host = __REMOTE_HOST__" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

EXPOSE 22
ENTRYPOINT ["/bin/tini", "--"]

CMD ["/usr/local/bin/docker-entrypoint.sh"]
