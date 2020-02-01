#!/bin/bash
# 
# Function: create CA signed certification
# Author: lhua
# Date: 2019-12-10
# Version: 1.0.0
#

openssl genrsa -out ca.key 2048
openssl req -key ca.key \
  -subj "/C=CN/ST=Shanghai/CN=ca-centre" -new -x509 -days 365 -out ca.crt
# create ca key and ca root certification

openssl genrsa -out server.key 2048
openssl req -key server.key \
  -subj "/C=CN/ST=Shanghai/CN=cloud-ctl" -new -out server.csr
openssl x509 -req -in server.csr \
  -CAkey ca.key -CA ca.crt -CAcreateserial -days 365 -out server.crt
# use ca key singed server certification

