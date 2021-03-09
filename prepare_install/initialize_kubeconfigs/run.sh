#!/bin/sh
. functions.sh

KUBE_PATH=$HOME/kubernetes
KUBECONF_PATH=$KUBE_PATH/config
CERT_DIR=$KUBE_PATH/ca/certs
KEY_DIR=$KUBE_PATH/ca/private
CA=ca

CLUSTER='SeaShell'
SERVER_PORT='6443'
SYS_GROUP='system:'
ADM_GROUP=' '

LOADBALANCER=192.168.5.30
LOCALHOST=127.0.0.1

CONTROLLERS=( 
    'kube-controller-manager' 
    'kube-scheduler' 
)

mkdir -p $KUBECONF_PATH

init_kubectl

display_stage "Initializing kubeconfigs"

display_update "Processing admin kubeconfig"
init_kubeconfig \
    admin \
    admin \
    $CLUSTER \
    $LOADBALANCER \
    $SERVER_PORT \
    $CERT_DIR \
    $KEY_DIR \
    $CA \
    $KUBECONF_PATH

display_update "Processing kube-proxy kubeconfig"
init_kubeconfig \
    kube-proxy \
    $SYS_GROUP \
    $CLUSTER \
    $LOADBALANCER \
    $SERVER_PORT \
    $CERT_DIR \
    $KEY_DIR \
    $CA \
    $KUBECONF_PATH

for component in "${CONTROLLERS[@]}"
do
    display_update "Processing $component kubeconfig"
    init_kubeconfig \
        $component \
        $SYS_GROUP \
        $CLUSTER \
        $LOCALHOST \
        $SERVER_PORT \
        $CERT_DIR \
        $KEY_DIR \
        $CA \
        $KUBECONF_PATH
done

display_update "Processing boostrap kubeconfig"
init_bootstrap_config \
    $KUBECONF_PATH \
    $LOADBALANCER