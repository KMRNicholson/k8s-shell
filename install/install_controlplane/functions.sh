init_directories()
{
    NODE=$1

    ssh $NODE 'sudo mkdir -p /etc/kubernetes/config /var/lib/kubernetes'
}

distribute_binaries()
{
    BIN_SOURCE=$1
    NODE=$2

    DEST=/usr/local/bin

    SCHED=$BIN_SOURCE/kube-scheduler
    CTL_MGR=$BIN_SOURCE/kube-controller-manager
    API_SVR=$BIN_SOURCE/kube-apiserver

    sudo scp $SCHED $CTL_MGR $API_SVR ${NODE}:${DEST}
}

distribute_cert_key_pairs()
{
    CA_CRT=$1
    CA_KEY=$2
    API_CRT=$3
    API_KEY=$4
    ETCD_CRT=$5
    ETCD_KEY=$6
    SVC_CRT=$7
    SVC_KEY=$8

    NODE=$9

    DEST=/var/lib/kubernetes

    sudo scp \
        $CA_CRT \
        $CA_KEY \
        $API_CRT \
        $API_KEY \
        $ETCD_CRT \
        $ETCD_KEY \
        $SVC_CRT \
        $SVC_KEY \
        ${NODE}:${DEST}
}

distribute_encryption_key()
{
    NODE=$1
    SRC=$2

    DEST=/var/lib/kubernetes

    sudo scp $SRC ${NODE}:${DEST}
}

distribute_kubeconfigs()
{
    SCHED=$1
    CTL_MGR=$2
    
    NODE=$3

    DEST=/var/lib/kubernetes

    sudo scp $SCHED $CTL_MGR ${NODE}:${DEST} 
}

distribute_service_file()
{
    SCHED=$1
    CTL_MGR=$2
    API_SERVER=$3

    NODE=$4

    DEST=/etc/systemd/system

    sudo scp $SCHED $CTL_MGR $API_SERVER ${NODE}:${DEST} 
}

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