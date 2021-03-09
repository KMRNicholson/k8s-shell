#!/bin/sh
. functions.sh

LB_HOST=loadbalancer
LB_IP=192.168.5.30
PORT=6443
HAPROXY_DIR=/etc/haproxy

display_stage "Installing haproxy on $LB_HOST"
install_haproxy $LB_HOST

display_stage "Distributing haproxy.cnf to $LB_HOST"
init_haproxy_cnf \
    $LB_HOST \
    $LB_IP \
    $PORT \
    $HAPROXY_DIR