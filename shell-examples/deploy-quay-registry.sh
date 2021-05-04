#!/bin/bash

# Configure Red Hat Quay v3 internal registry.
# Deploy method through docker-1.13.1 engine.
#    
# * issue: 
#     If use podman engine, quay container always can't 
#     be deployed successfully, and 443 port is always 
#     connected refused!
#
# * use method:
#     1. run `config_quay' function
#     2. config quay through Web UI
#     3. run `deploy_quay' function
#    
# Created by hualf on 2020-08-03.

function config_quay() {
  ### Install Docker ###
  echo "[*] Check docker package..."
  if `rpm -q docker > /dev/null`; then
    echo "    ---> Docker has been installled..."
  else
    echo "    ---> Install docker package..."
    yum install -y docker
    systemctl enable docker.service
    systemctl start docker.service
  fi
  
  ### Create MySQL database container ###
  echo "[*] Create MySQL database container..."
  mkdir -p /var/lib/mysql
  chmod 777 /var/lib/mysql
  export MYSQL_CONTAINER_NAME=quay-mysql
  export MYSQL_DATABASE=enterpriseregistrydb
  export MYSQL_PASSWORD=redhat
  export MYSQL_USER=quayuser
  export MYSQL_ROOT_PASSWORD=redhat
  
  if `docker images | grep mysql > /dev/null`; then
    echo "    ---> mysql-57-rhel container image downloaded..."
  else
    echo "    ---> Loading mysql-57-rhel container image..."
    docker load --input /root/mysql-57-rhel7.tar
  fi
  
  docker run \
    --detach \
    --restart=always \
    --env MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
    --env MYSQL_USER=${MYSQL_USER} \
    --env MYSQL_PASSWORD=${MYSQL_PASSWORD} \
    --env MYSQL_DATABASE=${MYSQL_DATABASE} \
    --name ${MYSQL_CONTAINER_NAME} \
    --privileged=true \
    --publish 3306:3306 \
    -v /var/lib/mysql:/var/lib/mysql/data:Z \
    registry.access.redhat.com/rhscl/mysql-57-rhel7
  
  ### Create Redis database container ###
  echo "[*] Create Redis database container..."
  mkdir -p /var/lib/redis
  chmod 777 /var/lib/redis
  
  if `docker images | grep redis > /dev/null`; then
    echo "    ---> redis-32-rhel7 container image downloaded..."
  else
    echo "    ---> Loading redis-32-rhel7 container image..."
    docker load --input /root/redis-32-rhel7.tar
  fi
  
  docker run \
    --detach \
    --restart=always \
    --publish 6379:6379 \
    --privileged=true \
    --name quay-redis \
    -v /var/lib/redis:/var/lib/redis/data:Z \
    registry.access.redhat.com/rhscl/redis-32-rhel7
  
  ### Login Red Hat Quay v3 registry ###
  # echo "[*] Login Red Hat Quay v3 registry..."
  # podman login -u="redhat+quay" -p="O81WSHRSJR14UAZBK54GQHJS0P1V4CLWAJV1X2C4SD7KO59CQ9N3RE12612XU1HR" quay.io
  
  ### Load Red Hat Quay v3 container image ###
  echo "[*] Load Red Hat Quay v3 container image..."
  if `docker images | grep quay > /dev/null`; then
    echo "    ---> quay container image downloaded..."
  else
    echo "    ---> Loading quay container image..."
    docker load --input /root/quay330.tar
  fi
  
  ### Configure Quay container ###
  docker run \
    --detach \
    --privileged=true \
    --name quay-config \
    --publish 8443:8443 \
    quay.io/redhat/quay:v3.3.0 \
    config redhat
}

### Note ###
# After running docker config quay, you must login https://<register_url>:8443
# as quayuser/redhat. During quay configuration, quay config will insert MySQL 
# and test connection with MySQL database.
# So you can't use quay configuration file directly in script which will result
# quay container can't be deployed successfully!

function deploy_quay() {
  ### Copy Quay config file ###
  echo "[*] Copy Quay config file..."
  mkdir -p /mnt/quay/{config,storage}
  cp /root/config.yaml /mnt/quay/config/
  
  ### Create self-signed certification ###
  echo "[*] Create Quay self-signed certification..."
  openssl req \
    -newkey rsa:2048 -nodes -keyout /root/ssl.key \
    -x509 -days 3650 -out /root/ssl.cert \
    -subj "/C=CN/ST=Shanghai/L=Shanghai/O=RedHat/OU=RedHat/CN=*.openshift4.example.com"
  
  sed -i 's/PREFERRED_URL_SCHEME: http/PREFERRED_URL_SCHEME: https/' /mnt/quay/config/config.yaml
  
  echo "    ---> Copy Quay self-signed certification..."
  cp /root/{ssl.key,ssl.cert} /mnt/quay/config/
  cp /root/ssl.cert /etc/pki/ca-trust/source/anchors/ssl.cert
  update-ca-trust extract
  
  ### Stop quay-config container ###
  echo "[*] Stop quay-config container..."
  docker stop quay-config && docker rm quay-config
  
  ### Deploy Red Hat Quay v3 registry ###
  echo "[*] Deploy Red Hat Quay v3 registry..."
  docker run \
    --detach \
    --restart=always \
    --sysctl net.core.somaxconn=4096 \
    --privileged=true \
    --name quay-master \
    -v /mnt/quay/config:/conf/stack:Z \
    -v /mnt/quay/storage:/datastorage:Z \
    -p 443:8443 \
    -p 80:8080 \
    quay.io/redhat/quay:v3.3.0
  
  ### Verfify quay-associated container ###
  echo "[*] Verify quay-associated container..."
  docker ps
}

config_quay
#deploy_quay
### When use `config_quay', comment `deploy_quay' vice versa.

