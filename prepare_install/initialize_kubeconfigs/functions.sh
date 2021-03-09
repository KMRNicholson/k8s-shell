init_kubectl()
{
	sudo cp $HOME/kubernetes/components/kubectl /usr/local/bin
}

init_kubeconfig()
{
	#Cluster and component info
	COMPONENT=$1
	GROUP=$2
	CLUSTER=$3
	SERVER_IP=$4
	SERVER_PORT=$5

	#Paths to certs and keys
	CERT_DEST=$6
	KEY_DEST=$7
	CA=$8
	
	DEST=$9

	# Variables used
	CA_CRT=$CERT_DEST/$CA.crt
	CERT=$CERT_DEST/$COMPONENT.crt
	KEY=$KEY_DEST/$COMPONENT.key

	[[ $COMPONENT = admin ]] && GROUP=''

	USER=${GROUP}$COMPONENT

	KUBECONFIG=$COMPONENT.kubeconfig
	SERVER=https://$SERVER_IP:$SERVER_PORT

	sudo kubectl config set-cluster $CLUSTER \
		--certificate-authority=$CA_CRT \
		--embed-certs=true \
		--server=$SERVER \
		--kubeconfig=$KUBECONFIG

	sudo kubectl config set-credentials $USER \
		--client-certificate=$CERT \
		--client-key=$KEY \
		--embed-certs=true \
		--kubeconfig=$KUBECONFIG

	sudo kubectl config set-context default \
		--cluster=$CLUSTER \
		--user=$USER \
		--kubeconfig=$KUBECONFIG

	sudo kubectl config use-context default --kubeconfig=$KUBECONFIG

	sudo mv $KUBECONFIG $DEST
}

init_bootstrap_config()
{
	DEST=$1
	LB_IP=$2

	sudo kubectl config set-cluster bootstrap \
		--server=https://${LB_IP}:6443 \
		--certificate-authority=/var/lib/kubernetes/ca.crt \
		--kubeconfig=bootstrap-kubeconfig

	sudo kubectl config set-credentials kubelet-bootstrap \
		--token=07401b.f395accd246ae52d \
		--kubeconfig=bootstrap-kubeconfig

	sudo kubectl config set-context bootstrap \
		--user=kubelet-bootstrap \
		--cluster=bootstrap \
		--kubeconfig=bootstrap-kubeconfig
	
	sudo kubectl config use-context bootstrap --kubeconfig=bootstrap-kubeconfig

	sudo mv bootstrap-kubeconfig $DEST
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