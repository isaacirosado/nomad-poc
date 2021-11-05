#!/bin/bash
#Manually update DNAT rules so Traefik can find the LXC running instance (which lives in the bridged "lxcbr0" interface)
#We use Consul's API to extract the port and address Traefik knows about
set -xe
set -o errexit
set -o nounset
set -o pipefail

curl -s ${CONSUL_HTTP_ADDR}/v1/catalog/services | jq 'keys | .[]' | tr -d \" | while read name; do
  if [[ ${name} = lxc* ]]; then
    export ID=`curl -s ${CONSUL_HTTP_ADDR}/v1/catalog/service/${name} | jq '.[].ServiceID' | tr -d \" | sed -e "s|^_nomad-task-||g" -e "s|-group.*||g"`
    export NODE=`curl -s ${CONSUL_HTTP_ADDR}/v1/catalog/service/${name} | jq '.[].Node' | tr -d \"`
    export DADDR=`curl -s ${CONSUL_HTTP_ADDR}/v1/catalog/service/${name} | jq '.[].Address' | tr -d \"`
    export DPORT=`curl -s ${CONSUL_HTTP_ADDR}/v1/catalog/service/${name} | jq '.[].ServicePort' | tr -d \"`
    export BRADDR=`pdsh -Nw${NODE} lxc-info ${name}-${ID} -iH`

    pdsh -Ngclient bash -c \"iptables -t nat -nL PREROUTING --line \| grep :${DPORT} \| grep -Eo ^[0-9]+ \| xargs -rILN iptables -t nat -D PREROUTING LN\"
    pdsh -Nw${NODE} iptables -t nat -A PREROUTING -p tcp -i eth1 -d ${DADDR} --dport ${DPORT} -j DNAT --to-destination ${BRADDR}:2368
    pdsh -Nw${NODE} iptables -t nat -A OUTPUT -p tcp --dport ${DPORT} -d ${DADDR} -j DNAT --to-destination ${BRADDR}:2368
  fi
done
