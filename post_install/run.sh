#!/bin/sh
. functions.sh

STEPS=(
    'component'
    'node'
    'deployment'
    'pod'
)

display_stage "Checking cluster healthz"

display_update "Sleeping for 60 seconds to allow cluster to setup"
sleep 60

display_update "Checking etcd health"
check_etcd_health master-1
sleep 2

for step in "${STEPS[@]}"
do
    display_update "Checking $step health"
    check_${step}_health
    sleep 2
done

display_update "Checking loadbalancer health"
check_loadbalancer_health 192.168.5.30
sleep 2