#!/bin/sh
. functions.sh

K8S_PATH=$HOME/kubernetes
BIN_PATH=$K8S_PATH/components

CA_PATH=$K8S_PATH/ca
CERTS_PATH=$CA_PATH/certs
CA=ca
CA_CRT_PATH=$CERTS_PATH/$CA.crt

CONFIGPATH=$K8S_PATH/config
BOOTSTRAP_CNF=$CONFIGPATH/bootstrap-kubeconfig
PROXY_CNF=$CONFIGPATH/kube-proxy.kubeconfig

SVC_PATH=$K8S_PATH/service/workers
KUBELET_SVC=$SVC_PATH/kubelet.service
PROXY_SVC=$SVC_PATH/kube-proxy.service

RES_PATH=$K8S_PATH/resource
KUBELET_RES=$RES_PATH/kubelet-config.yaml
PROXY_RES=$RES_PATH/kube-proxy-config.yaml

WORKERS=(
    'worker-1'
    'worker-2'
)

for worker in "${WORKERS[@]}"
do
    display_stage "Preparing TLS Node Authentication on $worker"

    display_update "Initializing directories"
    init_directories $worker

    display_update "Distributing binaries"
    distribute_binaries $BIN_PATH $worker

    display_update "Distributing cert/key pairs"
    distribute_cert_key_pairs \
        $CA_CRT_PATH \
        $worker

    display_update "Distributing kubeconfigs"
    distribute_kubeconfigs \
        $BOOTSTRAP_CNF \
        $PROXY_CNF \
        $worker

    display_update "Distributing resource files"
    distribute_resources \
        $KUBELET_RES \
        $PROXY_RES \
        $worker

    display_update "Distributing service files"
    distribute_service_file \
        $KUBELET_SVC \
        $PROXY_SVC \
        $worker

    display_update "Installation Complete!"
    sleep 3
done