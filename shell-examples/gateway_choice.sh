#!/bin/bash
# 
# Programme: choose available gateway.
# Author   : Longfei Hua
# Date	   : 2019-01-05 release.

GREEN='\033[32m'
NC='\033[0m'
GWs="10.197.11.191 172.31.216.1 192.168.43.1"

echo "`date +'%Y%m%d %H:%M:%S'` ----- GET DEFAULT GATEWAY -----"
if `route -n | grep -q '^0.0.0.0'`; then
	DEFAULT_GW=`route -n | awk '/^0.0.0.0/ {print $2}'`
	IFACE=`route -n | awk '/^0.0.0.0/ {print $NF}'`
	ping -c5 ${DEFAULT_GW} > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo -e "[ ${GREEN}Note${NC} ] Current default gateway: ${GREEN}${DEFAULT_GW}${NC}"
		echo -e "\nCurrent system routing table as following:"
		route -n
		exit 0
	else
		route del -net default gw ${DEFAULT_GW} dev ${IFACE}
		for GW in `echo ${GWs}`; do
			echo "--> Try to connect gateway ${GW} ..."
			if `ping -c5 ${GW} > /dev/null 2>&1`; then
				route add -net default gw ${GW} dev ${IFACE} && \
				  echo -e "[ ${GREEN}Note${NC} ] Current default gateway: ${GREEN}${GW}${NC}"
				echo -e "\nCurrent system routing table as following:"
				route -n
				exit 0
			else
				echo "---> ${GW} gateway not connect ..."
			fi
		done
	fi
else
	for GW in `echo ${GWs}`; do
        echo "--> Try to connect gateway ${GW} ..."
        if `ping -c5 ${GW} > /dev/null 2>&1`; then
            route add -net default gw ${GW} && \
              echo -e "[ ${GREEN}Note${NC} ] Current default gateway: ${GREEN}${GW}${NC}"
			echo -e "\nCurrent system routing table as following:"
			route -n
			exit 0
        else
            echo "---> ${GW} gateway not connect ..."
        fi
    done
fi
