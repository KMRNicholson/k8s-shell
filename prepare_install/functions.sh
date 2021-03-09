stop_worker()
{
    NODE=$1

    BIN=/usr/local/bin

    ssh $NODE \
        'sudo systemctl stop kubelet kube-proxy
        sudo systemctl disable kubelet kube-proxy
        sudo rm -f $BIN/kubelet $BIN/kube-proxy'
}

delete_resources()
{
    kubectl delete secrets bootstrap-token-07401b --namespace kube-system
    sleep 2
    kubectl delete clusterrolebinding create-csrs-for-bootstrapping
    sleep 2
    kubectl delete clusterrolebinding auto-approve-csrs-for-group
    sleep 2
    kubectl delete clusterrolebinding auto-approve-renewals-for-nodes
    sleep 2
    kubectl delete clusterrolebinding system:kube-apiserver
    sleep 2
    kubectl delete clusterrole system:kube-apiserver-to-kubelet
    sleep 2
}

stop_control_plane()
{
    NODE=$1

    BIN=/usr/local/bin

    ssh $NODE \
        'sudo systemctl stop kube-apiserver kube-controller-manager kube-scheduler
        sudo systemctl disable kube-apiserver kube-controller-manager kube-scheduler
        sudo rm -f $BIN/kube-apiserver $BIN/kube-controller-manager $BIN/kube-scheduler'
}

stop_etcd()
{
    NODE=$1

    BIN=/usr/local/bin

    ssh $NODE \
        'sudo systemctl stop etcd
        sudo systemctl disable etcd
        sudo rm -f $BIN/etcd $BIN/etcdctl'
}

stop_LB()
{
    NODE=$1

    ssh $NODE \
        'sudo systemctl stop haproxy
        sudo systemctl disable haproxy'
}

cleanup()
{
    sudo rm -r $HOME/kubernetes/
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