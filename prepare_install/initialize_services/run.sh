#!/bin/sh
. functions.sh

#Paths
SERVICE_DIR=$HOME/kubernetes/service
BIN_PATH=/usr/local/bin

#certs and keys
CA_CRT=ca.crt
CA_KEY=ca.key
ETCD_SRV_CRT=etcd-server.crt
ETCD_SRV_KEY=etcd-server.key
KUBE_API_CRT=kube-apiserver.crt
KUBE_API_KEY=kube-apiserver.key
SVC_CRT=service-account.crt
SVC_KEY=service-account.key

#Ip's and ports
NODE_IP=('192.168.5.11' '192.168.5.12')
LOCALHOST=127.0.0.1
CIDR=192.168.5.0
ETCD_PEER_PORT=2380
ETCD_CLIENT_PORT=2379

#Names
CLUSTER='SeaShell'
NODES=('master-1' 'master-2')

#configs
KUBE_CONTROLLER_CONF=kube-controller-manager.kubeconfig
KUBE_SCHEDULER_CONF=kube-scheduler.kubeconfig
KUBELET_KUBECONFIG=kubeconfig
KUBELET_CONFIG=kubelet-config.yaml
KUBELET_BOOTSTRAP_CONF=bootstrap-kubeconfig
KUBELET_CERT_DIR=pki

WORKERS_DIR=$SERVICE_DIR/workers

for i in 0 1
do
    display_stage "Initializing Service Unit Files for ${NODES[i]}"

    NODE_DIR=$SERVICE_DIR/${NODES[i]}
    mkdir -p $NODE_DIR
    sudo rm $NODE_DIR/* -f

    display_update "Initializing ETCD Service Unit File"
    init_etcd_server_service \
        $NODE_DIR \
        ${NODE_IP[i]} \
        $ETCD_CLIENT_PORT \
        $ETCD_PEER_PORT \
        $CA_CRT \
        $ETCD_SRV_CRT \
        $ETCD_SRV_KEY \
        ${NODES[i]} \
        'master-1=https://192.168.5.11:2380,master-2=https://192.168.5.12:2380'

    display_update "Initializing API Server Service Unit File"
    init_kube_apiserver_service \
        $NODE_DIR \
        ${NODE_IP[i]} \
        $CA_CRT \
        $KUBE_API_CRT \
        $KUBE_API_KEY \
        $ETCD_SRV_CRT \
        $ETCD_SRV_KEY \
        $SVC_CRT \
        'https://192.168.5.11:2379,https://192.168.5.12:2379'

    display_update "Initializing Controller Manager Service Unit File"
    init_kube_controller_manager_service \
        $NODE_DIR \
        $CIDR \
        $BIN_PATH \
        $CA_CRT \
        $CA_KEY \
        $SVC_KEY \
        $KUBE_CONTROLLER_CONF \
        $CLUSTER

    display_update "Initializing Scheduler Service Unit File"
    init_kube_scheduler_service \
        $NODE_DIR \
        $BIN_PATH \
        $KUBE_SCHEDULER_CONF
done

mkdir -p $WORKERS_DIR

display_stage "Initializing Kubelet Service Unit File for Workers"
init_kubelet_service \
    $WORKERS_DIR \
    $BIN_PATH \
    $KUBELET_KUBECONFIG \
    $KUBELET_CONFIG \
    $KUBELET_BOOTSTRAP_CONF \
    $KUBELET_CERT_DIR

display_stage "Initializing Kube Proxy Service Unit File for Workers"
init_kube_proxy_service $WORKERS_DIR