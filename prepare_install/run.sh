#!/bin/sh
. functions.sh

STEPS=(
    'download'
    'certificates'
    'kubeconfigs'
    'services'
    'resources'
)

CONTROL=(
    'master-1'
    'master-2'
)

WORKERS=(
    'worker-1'
    'worker-2'
)

LB=loadbalancer

display_stage "Stopping workers"
for node in "${WORKERS[@]}"
do
    display_update "Stopping services on $node"
    stop_worker $node
done

display_stage "Deleting RBAC resources"
delete_resources

display_stage "Stopping control plane"
for node in "${CONTROL[@]}"
do
    display_update "Stopping services on $node"
    stop_control_plane $node
done

display_stage "Stopping ETCD"
for node in "${CONTROL[@]}"
do
    display_update "Stopping services on $node"
    stop_etcd $node
done

display_stage "Stopping haproxy"
stop_LB $LB

cleanup

for task in "${STEPS[@]}"
do
    TASK_DIR=$PWD/initialize_$task

    cd $TASK_DIR
    . run.sh
    cd ..

    display_update "TASK: $task INITIALIZED! "
    sleep 3
done

sudo chmod +rw $HOME/kubernetes/**/*