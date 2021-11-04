#!/bin/bash
set -e
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

    pdsh -Nw${NODE} iptables -t nat -A PREROUTING -p tcp -i eth1 -d ${DADDR} --dport ${DPORT} -j DNAT --to-destination ${BRADDR}:2368
    pdsh -Nw${NODE} iptables -t nat -A OUTPUT -p tcp --dport ${DPORT} -d ${DADDR} -j DNAT --to-destination ${BRADDR}:2368
  fi
done
