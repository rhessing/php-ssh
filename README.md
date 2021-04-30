# php-sshd
A PHP CLI image that includes composer, multiple tools and a SSH server to connect to using Visual Studio Code

### Optionally these options can be started:
- Xdebug
- SSH

## Default SSH user
The default user for SSH login is php. The user does not have a password set, a public key is required.

## Public key
The public key is configured using a bind mount. The location within the container is: /home/php/.ssh/authorized_keys

## PHP options
The following environment options may be set, if not set the default values are used.

| Variable  | PHP setting | Default value |
| ------------- | ------------- |
| TIMEZONE | date.timezone | Etc/UTC  |
| ERROR_REPORTING | error_reporting | E_ALL |
| DISPLAY_ERRORS | display_errors | on |
| DISPLAY_STARTUP_ERRORS | display_startup_errors | on |
| REMOTE_PORT | xdebug.remote_port | 9000 |
| REMOTE_ENABLE | xdebug.remote_enable | 1 |
| REMOTE_AUTOSTART | xdebug.remote_autostart | 1 |
| REMOTE_HOST | xdebug.remote_host | host.docker.internal |
| IDEKEY | xdebug.idekey | VSC |
| FILE_LINK_FORMAT | xdebug.file_link_format | vscode://file/%f:%l |

### Image purpose
This docker image is meant to be used for development purposes it is not meant to be used in production. For production it is better to use other images which have a smaller footprint and do not include development options such as composer, xdebug and SSH. 
