check_etcd_health()
{
    NODE=$1

    ssh $NODE \
        'sudo ETCDCTL_API=3 etcdctl member list \
            --endpoints=https://127.0.0.1:2379 \
            --cacert=/etc/etcd/ca.crt \
            --cert=/etc/etcd/etcd-server.crt \
            --key=/etc/etcd/etcd-server.key'
}

check_component_health()
{
    kubectl get cs
}

check_node_health()
{
    kubectl get nodes
}

check_deployment_health()
{
    kubectl get deploy --all-namespaces
}

check_pod_health()
{
    kubectl get pod --all-namespaces
}

check_loadbalancer_health()
{
    IP=$1

    curl  https://$IP:6443/version -k
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