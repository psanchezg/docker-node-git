# docker-node-git

## build
**For node 4.9.x (Argon)**
```
docker build --build-arg="DISTRO_VER=4.9.1" --build-arg="NODE_VERSION=4.9.1" -t psanchezg/node-git:4.9.1 .
```

**For node 6.x (Boron)**
```
docker build --build-arg="DISTRO_VER=6.17.1" --build-arg="NODE_VERSION=6.17.1" -t psanchezg/node-git:6.17.1 .
```

**For node 8.x (Carbon)**
```
docker build --build-arg="DISTRO_VER=8.17.0" --build-arg="NODE_VERSION=8.17.0" -t psanchezg/node-git:8.17.0 .
```

**For node 10.x (Dubnium)**
```
docker build --build-arg="DISTRO_VER=10.24.1" --build-arg="NODE_VERSION=10.24.1" -t psanchezg/node-git:10.24.1 .
```

**For node 12.x (Erbium)**
```
docker build --build-arg="DISTRO_VER=12.22.12" --build-arg="NODE_VERSION=12.22.12" -t psanchezg/node-git:12.22.12 .
```

**For node 14.x (Fermium)**
```
docker build --build-arg="DISTRO_VER=14.21.3" --build-arg="NODE_VERSION=14.21.3" -t psanchezg/node-git:14.21.3 .
```

**For node 16.x (Gallium)**
```
docker build --build-arg="DISTRO_VER=16.20.2" --build-arg="NODE_VERSION=16.20.2" -t psanchezg/node-git:16.20.2 .
```

**For node 18.x (Hydrogen)**
```
docker build --build-arg="DISTRO_VER=18.18.2" --build-arg="NODE_VERSION=18.18.2" -t psanchezg/node-git:18.18.2 .
```

## Running

**To simply run the container:**
```
docker run -d psanchezg/node-git:10
docker run -d psanchezg/node-git:dubnium
docker run -d psanchezg/node-git:10.24.1
```

**To dynamically pull code from git when starting:**
```
docker run -d -e 'GIT_EMAIL=email_address' -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'GIT_PERSONAL_TOKEN=<long_token_string_here>' -e 'GIT_BRANCH=main' -e 'WEBROOT=/var/www/app' --name container-name psanchezg/node-git:10
```

You can then browse to ```http://<DOCKER_HOST>``` to view the default install files. To find your ```DOCKER_HOST``` use the ```docker inspect``` to get the IP address (normally 172.17.0.2)
