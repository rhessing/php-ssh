# php-sshd
A PHP CLI image that includes composer, multiple tools and a SSH server to connect to using Visual Studio Code.

It's meant to be used for development purposes, for example if you want to debug or quickly test some PHP code.

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
| ------------- | ------------- | ------------- |
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

## Example on how to use the image in K8s
```
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: public-sshd-pubkey
  namespace: default
  labels:
    app: sshd-console
data:
  authorized_keys: |
    <ssh-rsa AAAAB...>
    <ssh-rsa AAAAB...>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sshd-console
  namespace: default
spec:
  selector:
    matchLabels:
      app: sshd-console
  replicas: 1
  template:
    metadata:
      labels:
        app: sshd-console
    spec:
      initContainers:
      - name: take-data-dir-ownership
        image: alpine:3
        command:
          - chown
          - -R
          - 1:1
          - /var/www
          - /home/php/.vscode-server
        volumeMounts:
          - mountPath: /var/www
            name: vol-public-www
          - mountPath: /home/php/.vscode-server
            name: vol-public-sshd-vscode
      containers:
      - name: sshd-console
        image: rhessing/php-sshd:latest
        imagePullPolicy: Always
        volumeMounts:
          - mountPath: /var/www
            name: vol-public-www
          - mountPath: /home/php/.vscode-server
            name: vol-public-sshd-vscode
          - mountPath: /home/php/.ssh/authorized_keys.cmap
            subPath: authorized_keys
            name: vol-public-sshd-pubkey
        ports:
          - containerPort: 22
      volumes:
      - name: vol-public-www
        hostPath:
          path: /storage/public/www
          type: DirectoryOrCreate
      - name: vol-public-sshd-vscode
        hostPath:
          path: /storage/public/sshd-vscode
          type: DirectoryOrCreate
      - name: vol-public-sshd-pubkey
        configMap:
          name: public-sshd-pubkey
          defaultMode: 384
---
apiVersion: v1
kind: Service
metadata:
  name: sshd-console
  namespace: default
  labels:
    app: sshd-console
spec:
  selector:
    app: sshd-console
  type: NodePort
  ports:
    - name: ssh
      protocol: TCP
      nodePort: 32222
      port: 22
```