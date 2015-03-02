#!/bin/bash

if [ $1 = "--host" ] || [ -z "$OAR_NODE_FILE" ]; then
    echo "{}"
    exit 0
fi

nodes=($(sort -uV $OAR_NODE_FILE))

cat <<EOF
{
    "controller" : [ "${nodes[0]}" ],
    "network"    : [ "${nodes[0]}" ]
    "compute"    : [ "$(echo ${nodes[@]:1} | perl -lane 'print join "\", \"", @F')" ]
}
EOF

