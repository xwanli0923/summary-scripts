#!/bin/bash
#
# Monitor HAproxy process on kube-master nodes.
#

COUNT=`ps -C haproxy --no-header | wc -l`
if [ ${COUNT} -eq 0 ]; then
  systemctl start haproxy.service
  sleep 5s
  if [ `ps -C haproxy --no-header | wc -l` -eq 0 ]; then
    systemctl stop keepalived.service		
  fi
fi
