install_haproxy()
{
    NODE=$1

    sudo ssh $NODE 'sudo apt-get update && apt-get install -y haproxy'
}


init_haproxy_cnf()
{
    NODE=$1
    IP=$2
    PORT=$3

    DEST=$4

    cat <<EOF | sudo tee haproxy.cfg 
    frontend kubernetes
        bind ${IP}:${PORT}
        option tcplog
        mode tcp
        default_backend kubernetes-master-nodes

    backend kubernetes-master-nodes
        mode tcp
        balance roundrobin
        option tcp-check
        server master-1 192.168.5.11:6443 check fall 3 rise 2
        server master-2 192.168.5.12:6443 check fall 3 rise 2
EOF

    sudo scp haproxy.cfg ${NODE}:${DEST}
    sudo rm haproxy.cfg -f
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