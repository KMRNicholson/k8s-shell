#!/bin/sh
. functions.sh

STEPS=(
    'etcd'
    'controlplane'
    'loadbalancer'
    'worker'
    'admin'
)

display_stage()
{
    MSG=$1
    BLUE=$(tput setaf 4)
    WHITE=$(tput setaf 7)

    echo
    echo "${BLUE}****************************************"
    echo "${BLUE}*${WHITE} $MSG"
    echo "${BLUE}****************************************"
}

display_update()
{
    MSG=$1
    BLUE=$(tput setaf 4)
    WHITE=$(tput setaf 7)

    echo
    echo "${BLUE}**********"
    echo "${BLUE}*${WHITE} $MSG"
    echo "${BLUE}**********"
}

for task in "${STEPS[@]}"
do
    TASK_DIR=$PWD/install_$task

    cd $TASK_DIR
    . run.sh
    cd ..

    display_update "TASK: $task INSTALLED! "
    sleep 3
done

cd $PWD/start
. run.sh
cd ..