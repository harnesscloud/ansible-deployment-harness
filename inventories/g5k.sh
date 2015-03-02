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

openstack_network_external_ip=$(g5k-subnets -i | head -1)
openstack_network_external_netmask=$(g5k-subnets -p | perl -F/ -lane 'print $F[1]')
openstack_network_external_network=$(g5k-subnets -p)
openstack_network_external_allocation_pool_start=$(g5k-subnets -i | head -2 | tail -1)
openstack_network_external_allocation_pool_end=$(g5k-subnets -i | tail -1)
openstack_network_external_dns_servers=$(g5k-subnets -d | perl -lane 'print $F[-1]')

# FIXME: netmask?

cat <<EOF
{
    "controller" : {
        "hosts" : [ "${nodes[0]}" ],
        "vars"  : {
            "openstack_network_external_ip" : "$openstack_network_external_ip",
            "openstack_netmask_external_netmask" : "$openstack_network_external_netmask",
            "openstack_network_external_network" : "$openstack_network_external_network",
            "openstack_network_external_allocation_pool_start" : "$openstack_network_external_allocation_pool_start",
            "openstack_network_external_allocation_pool_end" : "$openstack_network_external_allocation_pool_end",
            "openstack_network_external_dns_servers" : "$openstack_network_external_dns_servers"
        }
    },
    "network"    : {
        "hosts" : [ "${nodes[0]}" ],
        "vars"  : {
            "openstack_network_external_ip" : "$openstack_network_external_ip",
            "openstack_netmask_external_netmask" : "$openstack_network_external_netmask",
            "openstack_network_external_network" : "$openstack_network_external_network",
            "openstack_network_external_allocation_pool_start" : "$openstack_network_external_allocation_pool_start",
            "openstack_network_external_allocation_pool_end" : "$openstack_network_external_allocation_pool_end",
            "openstack_network_external_dns_servers" : "$openstack_network_external_dns_servers"
        }
    },
    "compute"    : {
        "hosts" : [ "$(echo ${nodes[@]:1} | perl -lane 'print join "\", \"", @F')" ],
        "vars"  : {
            "openstack_network_external_ip" : "$openstack_network_external_ip",
            "openstack_netmask_external_netmask" : "$openstack_network_external_netmask",
            "openstack_network_external_network" : "$openstack_network_external_network",
            "openstack_network_external_allocation_pool_start" : "$openstack_network_external_allocation_pool_start",
            "openstack_network_external_allocation_pool_end" : "$openstack_network_external_allocation_pool_end",
            "openstack_network_external_dns_servers" : "$openstack_network_external_dns_servers"
        }
    }
}
EOF

