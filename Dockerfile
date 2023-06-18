FROM php:zts-bullseye
MAINTAINER R. Hessing

# Set default timezone to UTC
ENV TZ=Etc/UTC
ENV TINI_VERSION v0.19.0

# Install requirements for Tini and PHP extension builds
RUN apt-get update && apt-get install --no-install-recommends -y \
        default-mysql-client \
        dirmngr \
        g++ \
        git \
        gettext \
        libaspell-dev \
        libpspell-dev \
        libgmp-dev \
        libyaml-dev \
        libldap2-dev \
        libxslt1-dev \
        libxml2-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libicu-dev \
        libmcrypt-dev \
        libunistring-dev \
        libuv1-dev \
        libzip-dev \
        libmagickwand-dev \
        libmemcached-dev \
        libtidy-dev \
        libpq-dev \
        openssh-server \
        unzip \
        zip \
        zlib1g-dev \
        openssl \
        libssl-dev \
        libssh2-1-dev \
        libbz2-dev \
        libmagickwand-dev \
        libc-client-dev \
        libkrb5-dev \
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
    && mkdir -p /usr/app \
    && addgroup -gid 9876 dev \
    && adduser -uid 9876 -gid 9876 --shell /bin/bash --disabled-password --gecos '' dev \
    && passwd -u dev \
    && mkdir -p /home/dev/.ssh \
    && mkdir -p /home/dev/.vscode-server \
    && chown dev:dev /home/dev/.ssh \
    && chown dev:dev /home/dev/.vscode-server \
    && chmod 0700 /home/dev/.ssh \
    && ln -fsn /home/dev/app /usr/app

# Install parallel for PHP 8
RUN git clone https://github.com/krakjoe/parallel.git \
    && cd parallel \
    && phpize \
    && ./configure --enable-parallel  \
    && make \
    && make install \
    && docker-php-ext-enable parallel \
    && cd

# Install imagick for PHP 8
RUN git clone https://github.com/Imagick/imagick \
    && cd imagick \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && docker-php-ext-enable imagick \
    && cd

RUN pecl channel-update pecl.php.net

# Configure, build and install additional PHP extensions
RUN docker-php-ext-configure pcntl \
    && docker-php-ext-install -j$(nproc) pcntl \
    && docker-php-ext-enable pcntl

RUN docker-php-ext-configure sockets \
    && docker-php-ext-install -j$(nproc) sockets \
    && docker-php-ext-enable sockets

RUN docker-php-ext-configure bcmath \
    && docker-php-ext-install -j$(nproc) bcmath \
    && docker-php-ext-enable bcmath

RUN docker-php-ext-configure gettext \
    && docker-php-ext-install -j$(nproc) gettext \
    && docker-php-ext-enable gettext

RUN docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-enable intl

RUN docker-php-ext-configure exif \
    && docker-php-ext-install -j$(nproc) exif \
    && docker-php-ext-enable exif

RUN docker-php-ext-configure bz2 \
    && docker-php-ext-install -j$(nproc) bz2 \
    && docker-php-ext-enable bz2

RUN docker-php-ext-configure gmp \
    && docker-php-ext-install -j$(nproc) gmp \
    && docker-php-ext-enable gmp

RUN docker-php-ext-configure pspell \
    && docker-php-ext-install -j$(nproc) pspell \
    && docker-php-ext-enable pspell

RUN docker-php-ext-configure calendar \
    && docker-php-ext-install calendar \
    && docker-php-ext-enable calendar

RUN docker-php-ext-configure pdo_mysql \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable pdo_mysql

RUN docker-php-ext-configure pdo_pgsql \
    && docker-php-ext-install pdo_pgsql \
    && docker-php-ext-enable pdo_pgsql

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

RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable gd

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install ldap \
    && docker-php-ext-enable ldap

RUN docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install imap \
    && docker-php-ext-enable imap

RUN docker-php-ext-configure xsl \
    && docker-php-ext-install -j$(nproc) xsl \
    && docker-php-ext-enable xsl

RUN docker-php-ext-configure xml \
    && docker-php-ext-install -j$(nproc) xml \
    && docker-php-ext-enable xml

RUN docker-php-ext-configure sysvshm \
    && docker-php-ext-install -j$(nproc) sysvshm \
    && docker-php-ext-enable sysvshm

RUN docker-php-ext-configure sysvmsg \
    && docker-php-ext-install -j$(nproc) sysvmsg \
    && docker-php-ext-enable sysvmsg

RUN docker-php-ext-configure sysvsem \
    && docker-php-ext-install -j$(nproc) sysvsem \
    && docker-php-ext-enable sysvsem

RUN docker-php-ext-configure soap \
    && docker-php-ext-install -j$(nproc) soap \
    && docker-php-ext-enable soap

RUN pecl install lzf \
    && docker-php-ext-enable lzf

RUN pecl install ssh2-1.3.1 \
    && docker-php-ext-enable ssh2

RUN pecl install trader \
    && docker-php-ext-enable trader

RUN pecl install xlswriter \
    && docker-php-ext-enable xlswriter

RUN pecl install mcrypt \
    && docker-php-ext-enable mcrypt

RUN pecl install yaml \
    && docker-php-ext-enable yaml

RUN pecl install redis \
    && docker-php-ext-enable redis

RUN pecl install xhprof \
    && docker-php-ext-enable xhprof

RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

RUN pecl install ast \
    && docker-php-ext-enable ast

RUN pecl install igbinary \
    && docker-php-ext-enable igbinary

RUN pecl install ds \
    && docker-php-ext-enable ds

RUN pecl install msgpack \
    && docker-php-ext-enable msgpack

RUN pecl install oauth \
    && docker-php-ext-enable oauth

RUN pecl install pcov \
    && docker-php-ext-enable pcov

RUN pecl install psr \
    && docker-php-ext-enable psr

RUN pecl install uuid \
    && docker-php-ext-enable uuid

RUN pecl install apcu


# Cleanup
RUN rm -rf /tmp/* \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /parallel \
    && rm -rf /imagick \
    # Always refresh keys
    && rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

# Configure PHP
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && printf '[PHP]\ndate.timezone = "__TIMEZONE__"\n' > /usr/local/etc/php/conf.d/tzone.ini

EXPOSE 22
ENTRYPOINT ["/bin/tini", "--"]

CMD ["/usr/local/bin/docker-entrypoint.sh"]
