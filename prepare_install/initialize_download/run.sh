#!/bin/sh
. functions.sh

#Versions
K8S_VERSION=1.13.0
ETCD_VERSION=3.3.9
WEAVE_VERSION=0.7.5

#Paths
DEST=$HOME/kubernetes/components
CNI=$DEST/cni

COMPONENTS=(
    'kubectl' 
    'kube-apiserver' 
    'kube-controller-manager' 
    'kube-scheduler' 
    'kubelet'
    'kube-proxy'
)

mkdir -p $DEST
mkdir -p $CNI

display_stage "Downloading Components"
for component in "${COMPONENTS[@]}"
do
    display_update "Processing $component"
    download_component \
        $component \
        $K8S_VERSION \
        $DEST
done

display_stage "Downloading and Extracting ETCD"
download_and_extract_etcd $ETCD_VERSION $DEST

display_stage "Downloading and Extracting CNI"
download_and_extract_cni $WEAVE_VERSION $CNI