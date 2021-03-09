#!/bin/sh
. functions.sh

K8S_PATH=$HOME/kubernetes
BIN_PATH=$K8S_PATH/components

CA_PATH=$K8S_PATH/ca
CERTS_PATH=$CA_PATH/certs
KEY_PATH=$CA_PATH/private

CA=ca
ETCD=etcd-server
API=kube-apiserver
SVC=service-account

CA_CRT_PATH=$CERTS_PATH/$CA.crt
CA_KEY_PATH=$KEY_PATH/$CA.key
ETCD_CRT_PATH=$CERTS_PATH/$ETCD.crt
ETCD_KEY_PATH=$KEY_PATH/$ETCD.key
API_CRT_PATH=$CERTS_PATH/$API.crt
API_KEY_PATH=$KEY_PATH/$API.key
SVC_CRT_PATH=$CERTS_PATH/$SVC.crt
SVC_KEY_PATH=$KEY_PATH/$SVC.key

CONFIGPATH=$K8S_PATH/config
SCHEDCNF=$CONFIGPATH/kube-scheduler.kubeconfig
CTLMGRCNF=$CONFIGPATH/kube-controller-manager.kubeconfig

SVC_PATH=$K8S_PATH/service

RES_PATH=$K8S_PATH/resource

NODES=(
    'master-1'
    'master-2'
)

for node in "${NODES[@]}"
do 
    display_stage "Preparing Control Plane on $node"
    
    display_update "Initializing directories"
    init_directories $node

    display_update "Distributing binaries"
    distribute_binaries $BIN_PATH $node

    display_update "Distributing cert/key pairs"
    distribute_cert_key_pairs \
        $CA_CRT_PATH \
        $CA_KEY_PATH \
        $API_CRT_PATH \
        $API_KEY_PATH \
        $ETCD_CRT_PATH \
        $ETCD_KEY_PATH \
        $SVC_CRT_PATH \
        $SVC_KEY_PATH \
        $node

    display_update "Distributing encryption key"
    distribute_encryption_key \
        $node \
        $RES_PATH/encryption-config.yaml

    display_update "Distributing kubeconfigs"
    distribute_kubeconfigs \
        $SCHEDCNF \
        $CTLMGRCNF \
        $node

    display_update "Distributing service files"
    distribute_service_file \
        $SVC_PATH/$node/kube-scheduler.service \
        $SVC_PATH/$node/kube-controller-manager.service \
        $SVC_PATH/$node/kube-apiserver.service \
        $node

    display_update "Installation Complete!"
    sleep 3
done