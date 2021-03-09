#!/bin/sh
. functions.sh

#Paths
CA_PATH=$HOME/kubernetes/ca
KEY_DIR=$CA_PATH/private
CERT_DIR=$CA_PATH/certs
CNF_DIR=$PWD/openssl_cnfs

CA_NAME=ca
EXPIRY=1000 #days

COMPONENTS=(
    'admin' 
    'etcd-server' 
    'kube-apiserver' 
    'kube-controller-manager' 
    'kube-proxy' 
    'kube-scheduler' 
    'service-account' 
)

mkdir -p $KEY_DIR
mkdir -p $CERT_DIR

sudo chmod +rw $KEY_DEST
sudo chmod +rw $CERT_DEST

display_stage "Initializing CA Cert-Key Pair"
init_ca_crt_key_pair $CA_NAME $KEY_DIR $CERT_DIR $EXPIRY

display_stage "Initializing Component Cert-Key Pairs"
for component in "${COMPONENTS[@]}"
do
    OPENSSL_CNF="${CNF_DIR}/openssl-${component}.cnf"
    display_update "Processing ${component}"
    init_component_crt_key_pair \
        $CA_NAME \
        $component \
        $CERT_DIR \
        $KEY_DIR \
        $EXPIRY \
        $OPENSSL_CNF
done