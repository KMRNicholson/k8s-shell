init_etcd_server_service()
{
    DEST=$1
    
    INTERNAL_IP=$2
    CLIENT_PORT=$3
    PEER_PORT=$4

    CONFIG_FILE_DIR=/etc/etcd
    CA_CERT=$CONFIG_FILE_DIR/$5
    CERT=$CONFIG_FILE_DIR/$6
    KEY=$CONFIG_FILE_DIR/$7

    NODE=$8
    BIN_PATH=/usr/local/bin

    INIT_CLUSTER=$9

    cat <<EOF | sudo tee $DEST/etcd.service
    [Unit]
    Description=etcd
    Documentation=https://github.com/coreos

    [Service]
    ExecStart=$BIN_PATH/etcd \\
        --name $NODE \\
        --cert-file=$CERT \\
        --key-file=$KEY \\
        --peer-cert-file=$CERT \\
        --peer-key-file=$KEY \\
        --trusted-ca-file=$CA_CERT \\
        --peer-trusted-ca-file=$CA_CERT \\
        --peer-client-cert-auth \\
        --client-cert-auth \\
        --initial-advertise-peer-urls https://$INTERNAL_IP:$PEER_PORT \\
        --listen-peer-urls https://$INTERNAL_IP:$PEER_PORT \\
        --listen-client-urls https://$INTERNAL_IP:$CLIENT_PORT,https://127.0.0.1:$CLIENT_PORT \\
        --advertise-client-urls https://$INTERNAL_IP:$CLIENT_PORT \\
        --initial-cluster-token etcd-cluster-0 \\
        --initial-cluster $INIT_CLUSTER \\
        --initial-cluster-state new \\
        --data-dir=/var/lib/etcd
    Restart=on-failure
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
EOF
}

init_kube_apiserver_service()
{
    DEST=$1

    INTERNAL_IP=$2
    BIN_PATH=/usr/local/bin

    CONFIG_FILE_DIR=/var/lib/kubernetes
    CA_CERT=$CONFIG_FILE_DIR/$3
    CERT=$CONFIG_FILE_DIR/$4
    KEY=$CONFIG_FILE_DIR/$5
    ETCD_CRT=$CONFIG_FILE_DIR/$6
    ETCD_KEY=$CONFIG_FILE_DIR/$7
    SVC_ACC_CRT=$CONFIG_FILE_DIR/$8

    ETCD_SERVERS=$9

    cat <<EOF | sudo tee $DEST/kube-apiserver.service
    [Unit]
    Description=Kubernetes API Server
    Documentation=https://github.com/kubernetes/kubernetes

    [Service]
    ExecStart=$BIN_PATH/kube-apiserver \\
        --advertise-address=$INTERNAL_IP \\
        --allow-privileged=true \\
        --apiserver-count=3 \\
        --audit-log-maxage=30 \\
        --audit-log-maxbackup=3 \\
        --audit-log-maxsize=100 \\
        --audit-log-path=/var/log/audit.log \\
        --authorization-mode=Node,RBAC \\
        --bind-address=0.0.0.0 \\
        --client-ca-file=$CA_CERT \\
        --enable-admission-plugins=NodeRestriction,ServiceAccount \\
        --enable-swagger-ui=true \\
        --enable-bootstrap-token-auth=true \\
        --etcd-cafile=$CA_CERT \\
        --etcd-certfile=$ETCD_CRT \\
        --etcd-keyfile=$ETCD_KEY \\
        --etcd-servers=$ETCD_SERVERS \\
        --event-ttl=1h \\
        --encryption-provider-config=$CONFIG_FILE_DIR/encryption-config.yaml \\
        --kubelet-certificate-authority=$CA_CERT \\
        --kubelet-client-certificate=$CERT \\
        --kubelet-client-key=$KEY \\
        --kubelet-https=true \\
        --runtime-config=api/all \\
        --service-account-key-file=$SVC_ACC_CRT \\
        --service-cluster-ip-range=10.96.0.0/24 \\
        --service-node-port-range=30000-32767 \\
        --tls-cert-file=$CERT \\
        --tls-private-key-file=$KEY \\
        --v=2
    Restart=on-failure
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
EOF
}

init_kube_controller_manager_service()
{
    DEST=$1

    CIDR=$2
    BIN_PATH=$3

    CONFIG_FILE_DIR=/var/lib/kubernetes
    CA_CERT=$CONFIG_FILE_DIR/$4
    CAKEY=$CONFIG_FILE_DIR/$5
    SVC_ACC_KEY=$CONFIG_FILE_DIR/$6
    CONFIG=$CONFIG_FILE_DIR/$7

    CLUSTER_NAME=$8

    cat <<EOF | sudo tee $DEST/kube-controller-manager.service
    [Unit]
    Description=Kubernetes Controller Manager
    Documentation=https://github.com/kubernetes/kubernetes

    [Service]
    ExecStart=$BIN_PATH/kube-controller-manager \\
        --address=0.0.0.0 \\
        --cluster-cidr=$CIDR/24 \\
        --cluster-name=$CLUSTER_NAME \\
        --cluster-signing-cert-file=$CA_CERT \\
        --cluster-signing-key-file=$CAKEY \\
        --kubeconfig=$CONFIG \\
        --leader-elect=true \\
        --root-ca-file=$CA_CERT \\
        --service-account-private-key-file=$SVC_ACC_KEY \\
        --service-cluster-ip-range=10.96.0.0/24 \\
        --use-service-account-credentials=true \\
        --v=2
    Restart=on-failure
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
EOF
}

init_kube_scheduler_service()
{
    DEST=$1

    BIN_PATH=$2

    CONFIG_FILE_DIR=/var/lib/kubernetes
    CONFIG=$CONFIG_FILE_DIR/$3

    cat <<EOF | sudo tee $DEST/kube-scheduler.service
    [Unit]
    Description=Kubernetes Scheduler
    Documentation=https://github.com/kubernetes/kubernetes

    [Service]
    ExecStart=$BIN_PATH/kube-scheduler \\
        --kubeconfig=$CONFIG \\
        --address=127.0.0.1 \\
        --leader-elect=true \\
        --v=2
    Restart=on-failure
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
EOF
}

init_kubelet_service()
{
    DEST=$1

    BIN_PATH=$2

    CONFIG_FILE_DIR=/var/lib/kubelet
    KUBECONFIG=$CONFIG_FILE_DIR/$3
    CONFIG=$CONFIG_FILE_DIR/$4
    BOOTSTRAP_CONFIG=$CONFIG_FILE_DIR/$5
    CERT_DIR=$CONFIG_FILE_DIR/$6

    cat <<EOF | sudo tee $DEST/kubelet.service
    [Unit]
    Description=Kubernetes Kubelet
    Documentation=https://github.com/kubernetes/kubernetes
    After=docker.service
    Requires=docker.service

    [Service]
    ExecStart=$BIN_PATH/kubelet \\
        --bootstrap-kubeconfig="$BOOTSTRAP_CONFIG" \\
        --config=$CONFIG \\
        --image-pull-progress-deadline=2m \\
        --kubeconfig=$KUBECONFIG \\
        --cert-dir=$CERT_DIR \\
        --rotate-certificates=true \\
        --rotate-server-certificates=true \\
        --network-plugin=cni \\
        --register-node=true \\
        --v=2
    Restart=on-failure
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
EOF
}

init_kube_proxy_service()
{
    DEST=$1

    cat <<EOF | sudo tee $DEST/kube-proxy.service
    [Unit]
    Description=Kubernetes Kube Proxy
    Documentation=https://github.com/kubernetes/kubernetes

    [Service]
    ExecStart=/usr/local/bin/kube-proxy \\
        --config=/var/lib/kube-proxy/kube-proxy-config.yaml
    Restart=on-failure
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
EOF
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