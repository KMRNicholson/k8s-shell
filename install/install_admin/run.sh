#!/bin/sh

CNF_PATH=$HOME/kubernetes/config
ADM_CNF=$CNF_PATH/admin.kubeconfig

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

display_stage "Setting Kubectl config on administrator"
sudo cp $ADM_CNF $HOME/.kube/config 