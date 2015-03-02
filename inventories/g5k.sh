#!/bin/bash

if [ -z "$OAR_NODE_FILE" ]; then
    exit 0
fi

nodes=($(sort -uV $OAR_NODE_FILE))

cat <<EOF
{
    "controller" : [ "${nodes[0]}" ],
    "network"    : [ "${nodes[0]}" ],
    "compute"    : [ $(printf '"%s", ' ${nodes[@]:1})]
}
EOF

