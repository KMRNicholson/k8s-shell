init_directories()
{
    NODE=$1

    ssh $NODE 'sudo mkdir -p /etc/etcd /var/lib/etcd'
}

distribute_binaries()
{
    BIN_SOURCE=$1
    BIN_DEST=$2
    NODE=$3

    ETCD=$BIN_SOURCE/etcd
    ETCDCTL=$BIN_SOURCE/etcdctl

    sudo scp $ETCD $ETCDCTL ${NODE}:${BIN_DEST}
}

distribute_cert_key_pairs()
{
    CA_CRT_SRC=$1
    CRT_SRC=$2
    KEY_SRC=$3
    NODE=$4

    DEST=/etc/etcd

    sudo scp $CA_CRT_SRC $CRT_SRC $KEY_SRC ${NODE}:${DEST}
}

distribute_service_file()
{
    SVC_SOURCE=$1
    SVC_DEST=$2
    NODE=$3

    sudo scp $SVC_SOURCE ${NODE}:${SVC_DEST} 
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