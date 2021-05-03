FROM php:8-cli-alpine

MAINTAINER R. Hessing

# Set default timezone to UTC
ENV TZ=Etc/UTC
ENV LANG=C.UTF-8

# Credits for this belong to: https://github.com/Docker-Hub-frolvlad/docker-alpine-glibc
# This is needed for the Visual Studio Code SSH remote development plugin
# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.

RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.33-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    echo \
        "-----BEGIN PUBLIC KEY-----\
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        1QIDAQAB\
        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

RUN apk --update add \
        aspell-dev \
        autoconf \
        bash \
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
        libstdc++ \
        libzip-dev \
        make \
        openssh \
        tidyhtml-dev \
        tini \
        tzdata \
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
    && pecl install xdebug \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable xdebug \
    && composer self-update --2 \
    && apk del --no-cache \
      g++ \
      make \
    && rm -rf /tmp/* \
    && rm /var/cache/apk/* \
    # Always refresh keys
    && rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

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
