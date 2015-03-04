#!/bin/sh
kadeploy -f $OAR_NODE_FILE -e ubuntu-x64-1404 -k
ansible-playbook -i inventories/g5k.sh provisioning/prep.yml
ansible-playbook -i inventories/g5k.sh provisioning/deploy.yml
