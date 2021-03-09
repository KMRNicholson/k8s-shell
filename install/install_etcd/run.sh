#!/bin/sh
. functions.sh

K8S_PATH=$HOME/kubernetes
BIN_PATH=$K8S_PATH/components
NODE_BIN_PATH=/usr/local/bin
CA_PATH=$K8S_PATH/ca
CERTS_PATH=$CA_PATH/certs
KEY_PATH=$CA_PATH/private

CA=ca
ETCD=etcd-server

CA_CRT_PATH=$CERTS_PATH/$CA.crt
CRT_PATH=$CERTS_PATH/$ETCD.crt
KEY_PATH=$KEY_PATH/$ETCD.key

SVC_PATH=$K8S_PATH/service
NODE_SVC_PATH=/etc/systemd/system

NODES=(
    'master-1'
    'master-2'
)

for node in "${NODES[@]}"
do 
    display_stage "Preparing ETCD on $node"
    
    display_update "Initializing directories"
    init_directories $node

    display_update "Distributing binaries"
    distribute_binaries $BIN_PATH $NODE_BIN_PATH $node

    display_update "Distributing cert/key pairs"
    distribute_cert_key_pairs $CA_CRT_PATH $CRT_PATH $KEY_PATH $node

    display_update "Distributing service files"
    distribute_service_file $SVC_PATH/$node/etcd.service $NODE_SVC_PATH $node

    display_update "Installation Complete!"
    sleep 3
done