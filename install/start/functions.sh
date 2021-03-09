start_etcd()
{
    NODE=$1

    ssh $NODE \
        'sudo systemctl daemon-reload
        sudo systemctl enable etcd
        sudo systemctl restart etcd'
}

start_controlplane()
{
    NODE=$1

    ssh $NODE \
        'sudo systemctl daemon-reload
        sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
        sudo systemctl restart kube-apiserver kube-controller-manager kube-scheduler'
}

start_loadbalancer()
{
    NODE=$1

    ssh $NODE 'sudo service haproxy restart'
}

create_RBAC()
{
    BOOTSTRAP_TOKEN=$1
    
    kubectl create -f $BOOTSTRAP_TOKEN

    sleep 3
    
    kubectl create clusterrolebinding create-csrs-for-bootstrapping \
        --clusterrole=system:node-bootstrapper \
        --group=system:bootstrappers

    sleep 3

    kubectl create clusterrolebinding auto-approve-csrs-for-group \
        --clusterrole=system:certificates.k8s.io:certificatesigningrequests:nodeclient \
        --group=system:bootstrappers

    sleep 3

    kubectl create clusterrolebinding auto-approve-renewals-for-nodes \
        --clusterrole=system:certificates.k8s.io:certificatesigningrequests:selfnodeclient \
        --group=system:nodes
}

start_worker()
{
    NODE=$1

    ssh $NODE \
        'sudo systemctl daemon-reload
        sudo systemctl enable kubelet kube-proxy
        sudo systemctl restart kubelet kube-proxy'
}

start_cni()
{
    kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
}

create_api_to_kubelet_RBAC()
{
    CLUSTERROLE=$1
    CLUSTERROLEBINDING=$2
    
    kubectl apply -f $CLUSTERROLE
    kubectl apply -f $CLUSTERROLEBINDING
}

start_dns_svc()
{
    kubectl apply -f https://raw.githubusercontent.com/mmumshad/kubernetes-the-hard-way/master/deployments/coredns.yaml
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