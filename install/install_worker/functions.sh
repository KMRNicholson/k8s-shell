init_directories()
{
    NODE=$1

    ssh $NODE \
        'sudo mkdir -p \
            /etc/cni/net.d \
            /opt/cni/bin \
            /var/lib/kubelet \
            /var/lib/kube-proxy \
            /var/lib/kubernetes \
            /var/run/kubernetes'
}

distribute_binaries()
{
    BIN_SOURCE=$1
    NODE=$2

    DEST=/usr/local/bin
    CNI_DEST=/opt/cni/bin

    PROXY=$BIN_SOURCE/kube-proxy
    KUBELET=$BIN_SOURCE/kubelet
    CNI=$BIN_SOURCE/cni

    sudo scp $PROXY $KUBELET ${NODE}:${DEST}
    sudo scp $CNI/* ${NODE}:${CNI_DEST}
}

distribute_cert_key_pairs()
{
    CA_CRT=$1

    NODE=$2

    DEST=/var/lib/kubernetes

    sudo scp $CA_CRT ${NODE}:${DEST}
}

distribute_kubeconfigs()
{
    BOOTSTRAP=$1
    PROXY=$2
    
    NODE=$3

    KUBELET_DEST=/var/lib/kubelet
    PROXY_DEST=/var/lib/kube-proxy

    sudo scp $BOOTSTRAP ${NODE}:${KUBELET_DEST}
    sudo scp $PROXY ${NODE}:${PROXY_DEST}/kubeconfig
}

distribute_resources()
{
    KUBELET_CONF=$1
    PROXY_CONF=$2

    NODE=$3

    KUBELET_DEST=/var/lib/kubelet
    PROXY_DEST=/var/lib/kube-proxy

    sudo scp $KUBELET_CONF ${NODE}:${KUBELET_DEST}
    sudo scp $PROXY_CONF ${NODE}:${PROXY_DEST}
}

distribute_service_file()
{
    KUBELET=$1
    PROXY=$2

    NODE=$3

    DEST=/etc/systemd/system

    sudo scp $KUBELET $PROXY ${NODE}:${DEST}
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