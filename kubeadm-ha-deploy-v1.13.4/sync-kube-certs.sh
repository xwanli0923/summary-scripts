#!/bin/bash
#
# Sync kubernetes certifications to ha masters.
#

for NODE in kube-master1 kube-master2; do
  ssh root@${NODE} mkdir -p /etc/kubernetes/pki/etcd
  scp /etc/kubernetes/admin.conf root@${NODE}:/etc/kubernetes
  scp /etc/kubernetes/pki/{ca.*,sa.*,front-proxy-ca.*} root@${NODE}:/etc/kubernetes/pki
  scp /etc/kubernetes/pki/etcd/ca.* root@${NODE}:/etc/kubernetes/pki/etcd
done
