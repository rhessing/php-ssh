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

# Because kubernetes config maps cannot have a defined owner
# just move authorized_keys.cmap to the correct location and set the correct user
if [ -f "/home/dev/.ssh/authorized_keys.cmap" ]; then
  cp /home/dev/.ssh/authorized_keys.cmap /home/dev/.ssh/authorized_keys \
  && chmod 600 /home/dev/.ssh/authorized_keys \
  && chown dev:dev /home/dev/.ssh/authorized_keys
fi

# Set env controlled variables
TIMEZONE=${TIMEZONE:-Etc/UTC}

# Set PHP config
sed -i "s~__TIMEZONE__~${TIMEZONE}~g" /usr/local/etc/php/conf.d/tzone.ini

/usr/sbin/sshd -D -e
