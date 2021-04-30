#!/bin/sh
set -e

if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# generate fresh rsa key
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	# generate fresh dsa key
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi

#prepare run dir
if [ ! -d "/var/run/sshd" ]; then
  mkdir -p /var/run/sshd
fi

#create user .ssh dir
if [ ! -d "/home/php/.ssh" ]; then
  mkdir -p /home/php/.ssh
fi

# Set env controlled variables
TIMEZONE=${TIMEZONE:-Etc/UTC}
ERROR_REPORTING=${ERROR_REPORTING:-E_ALL}
IDEKEY=${IDEKEY:-VSC}
DISPLAY_ERRORS=${DISPLAY_ERRORS:-on}
DISPLAY_STARTUP_ERRORS=${DISPLAY_STARTUP_ERRORS:-on}
REMOTE_PORT=${REMOTE_PORT:-9000}
REMOTE_ENABLE=${REMOTE_ENABLE:-1}
REMOTE_AUTOSTART=${REMOTE_AUTOSTART:-1}
REMOTE_HOST=${REMOTE_HOST:-host.docker.internal}
FILE_LINK_FORMAT=${FILE_LINK_FORMAT:-vscode://file/%f:%l}

# Set PHP config
sed -i "s~__TIMEZONE__~${TIMEZONE}~g" /usr/local/etc/php/conf.d/tzone.ini
sed -i "s~__ERROR_REPORTING__~${ERROR_REPORTING}~g" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
sed -i "s~__DISPLAY_STARTUP_ERRORS__~${DISPLAY_STARTUP_ERRORS}~g" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
sed -i "s~__DISPLAY_ERRORS__~${DISPLAY_ERRORS}~g" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
sed -i "s~__FILE_LINK_FORMAT__~${FILE_LINK_FORMAT}~g" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
sed -i "s~__IDEKEY__~${IDEKEY}~g" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
sed -i "s~__REMOTE_PORT__~${REMOTE_PORT}~g" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
sed -i "s~__REMOTE_ENABLE__~${REMOTE_ENABLE}~g" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
sed -i "s~__REMOTE_AUTOSTART__~${REMOTE_AUTOSTART}~g" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
sed -i "s~__REMOTE_HOST__~${REMOTE_HOST}~g" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

/usr/local/ssdb/ssdb-server /usr/local/ssdb/ssdb.conf
