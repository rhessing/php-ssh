FROM php:8-cli-alpine

MAINTAINER R. Hessing

RUN apk --update add \
        aspell-dev \
        autoconf \
        bzip2-dev \
        composer \
        coreutils \
        freetype-dev \
        g++ \
        gettext \
        gettext-asprintf \
        gettext-dev \
        gettext-libs \
        git \
        gmp-dev \
        icu-dev \
        libgomp \
        libintl \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libunistring \
        libuv-dev \
        libzip-dev \
        make \
        openssh \
        tidyhtml-dev \
        tini \
        unzip \
        zip \
    && docker-php-ext-install -j$(nproc) iconv \
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
    && pecl install mcrypt \
    && pecl install redis \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-enable redis \
    && composer self-update --2 \
    && apk del --no-cache \
      g++ \
      make \
    && rm -rf /tmp/* \
    && rm /var/cache/apk/* \
    # Always refresh keys
    && rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

COPY docker-entrypoint.sh /usr/local/bin/
RUN mkdir -p /var/www \
    && chmod 755 /usr/local/bin/docker-entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/usr/local/bin/docker-entrypoint.sh"]
