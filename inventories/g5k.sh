#!/bin/bash

if [ "$1" = "--host" ] || [ -z "$OAR_NODE_FILE" ]; then
    echo "{}"
    exit 0
fi

nodes=($(sort -uV $OAR_NODE_FILE))

if [ ${#nodes[@]} -lt 2 ]; then
    echo "{}"
    exit 0
fi

openstack_network_external_network="$(g5k-subnets -GN)/14"
openstack_network_external_gateway=$(g5k-subnets -gN)
openstack_network_external_allocation_pool_start=$(g5k-subnets -i | head -1)
openstack_network_external_allocation_pool_end=$(g5k-subnets -i | tail -1)
openstack_network_external_dns_servers=$(g5k-subnets -d | perl -lane 'print $F[-1]')

cat <<EOF
{
    "controller" : {
        "hosts" : [ "${nodes[0]}" ]
    },
    "network"    : {
        "hosts" : [ "${nodes[0]}" ],
        "vars"  : {
            "openstack_network_external_network" : "$openstack_network_external_network",
            "openstack_network_external_gateway" : "$openstack_network_external_gateway",
            "openstack_network_external_allocation_pool_start" : "$openstack_network_external_allocation_pool_start",
            "openstack_network_external_allocation_pool_end" : "$openstack_network_external_allocation_pool_end",
            "openstack_network_external_dns_servers" : "$openstack_network_external_dns_servers"
        }
    },
    "compute"    : {
        "hosts" : [ "$(echo ${nodes[@]:1} | perl -lane 'print join "\", \"", @F')" ]
    }
}
EOF
