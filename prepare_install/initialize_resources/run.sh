#!/bin/sh
. functions.sh

K8S_PATH=$HOME/kubernetes
RES_PATH=$K8S_PATH/resource

mkdir -p $RES_PATH

display_stage "Initializing encryption-config.yaml"
init_encryption_key $RES_PATH

display_stage "Initializing bootstrap-token-<token id>.yaml"
init_bootstrap_token $RES_PATH

display_stage "Initializing kubelet-config.yaml"
init_kubelet_config $RES_PATH

display_stage "Initializing kube-proxy-config.yaml"
init_kube_proxy_config $RES_PATH

display_stage "Initializing api-to-kubelet-clusterrole"
init_api_to_kubelet_clusterrole $RES_PATH

display_stage "Initializing api-to-kubelet-clusterrolebinding"
init_api_to_kubelet_clusterrolebinding $RES_PATH