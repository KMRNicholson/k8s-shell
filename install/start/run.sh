#!/bin/sh
. functions.sh

BOOTSTRAP_TOKEN=$HOME/kubernetes/resource/bootstrap-token-07401b.yaml
RES_PATH=$HOME/kubernetes/resource

CONTROL=(
    'master-1'
    'master-2'
)

WORKERS=(
    'worker-1'
    'worker-2'
)

LB=loadbalancer

display_stage "Starting ETCD Cluster"
for node in "${CONTROL[@]}"
do
    display_update "Starting ETCD on $node"
    start_etcd $node
done

display_update "ETCD Cluster started. Waiting..."
sleep 5

display_stage "Starting Control Plane Services"
for node in "${CONTROL[@]}"
do
    display_update "Starting services on $node"
    start_controlplane $node
done

display_update "Control Plane services started. Waiting..."
sleep 5

display_stage "Starting haproxy on $LB"
start_loadbalancer $LB

display_update "haproxy started on $LB. Waiting..."
sleep 5

display_stage "Creating RBAC"
create_RBAC $BOOTSTRAP_TOKEN

display_update "RBAC created. Waiting..."
sleep 5

display_stage "Starting Worker Services"
for node in "${WORKERS[@]}"
do
    display_update "Starting services on $node"
    start_worker $node
done
display_update "Worker Services started. Waiting..."
sleep 5

display_stage "Starting CNI"
start_cni

display_update "CNI started. Waiting..."
sleep 5

display_stage "Authorizing access from kube-apiserver to kubelet"
create_api_to_kubelet_RBAC \
    $RES_PATH/api-to-kubelet-clusterrole.yaml \
    $RES_PATH/api-to-kubelet-clusterrolebinding.yaml

display_update "RBAC for kube-apiserver to kubelet created. Waiting..."
sleep 5

display_stage "Starting DNS Service"
start_dns_svc

display_update "DNS Service started."

display_stage "------ CLUSTER IS READY -------"