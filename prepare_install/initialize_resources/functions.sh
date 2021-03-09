init_encryption_key()
{
    DEST=$1

    ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

    cat > encryption-config.yaml <<EOF
    kind: EncryptionConfig
    apiVersion: v1
    resources:
      - resources:
          - secrets
        providers:
          - aescbc:
              keys:
                - name: key1
                  secret: ${ENCRYPTION_KEY}
          - identity: {}
EOF

    sudo mv encryption-config.yaml $DEST
}

init_bootstrap_token()
{
    DEST=$1

    cat > bootstrap-token-07401b.yaml <<EOF
    apiVersion: v1
    kind: Secret
    metadata:
      # Name MUST be of form "bootstrap-token-<token id>"
      name: bootstrap-token-07401b
      namespace: kube-system

    # Type MUST be 'bootstrap.kubernetes.io/token'
    type: bootstrap.kubernetes.io/token
    stringData:
      # Human readable description. Optional.
      description: "The default bootstrap token generated by 'kubeadm init'."

      # Token ID and secret. Required.
      token-id: 07401b
      token-secret: f395accd246ae52d

      # Expiration. Optional.
      expiration: 2021-03-10T03:22:11Z

      # Allowed usages.
      usage-bootstrap-authentication: "true"
      usage-bootstrap-signing: "true"

      # Extra groups to authenticate the token as. Must start with "system:bootstrappers:"
      auth-extra-groups: system:bootstrappers:worker
EOF

    sudo mv bootstrap-token-07401b.yaml $DEST
}

init_kubelet_config()
{
    DEST=$1

    cat <<EOF | sudo tee kubelet-config.yaml
    kind: KubeletConfiguration
    apiVersion: kubelet.config.k8s.io/v1beta1
    authentication:
      anonymous:
        enabled: false
      webhook:
        enabled: true
      x509:
        clientCAFile: "/var/lib/kubernetes/ca.crt"
    authorization:
      mode: Webhook
    clusterDomain: "cluster.local"
    clusterDNS:
      - "10.96.0.10"
    resolvConf: "/run/systemd/resolve/resolv.conf"
    runtimeRequestTimeout: "15m"
EOF

    sudo mv kubelet-config.yaml $DEST
}

init_kube_proxy_config()
{
    DEST=$1

    cat <<EOF | sudo tee kube-proxy-config.yaml
    kind: KubeProxyConfiguration
    apiVersion: kubeproxy.config.k8s.io/v1alpha1
    clientConnection:
      kubeconfig: "/var/lib/kube-proxy/kubeconfig"
    mode: "iptables"
    clusterCIDR: "192.168.5.0/24"
EOF

    sudo mv kube-proxy-config.yaml $DEST
}

init_api_to_kubelet_clusterrole()
{
    DEST=$1

    cat <<EOF | sudo tee api-to-kubelet-clusterrole.yaml
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRole
    metadata:
      annotations:
        rbac.authorization.kubernetes.io/autoupdate: "true"
      labels:
        kubernetes.io/bootstrapping: rbac-defaults
      name: system:kube-apiserver-to-kubelet
    rules:
      - apiGroups:
          - ""
        resources:
          - nodes/proxy
          - nodes/stats
          - nodes/log
          - nodes/spec
          - nodes/metrics
        verbs:
          - "*"
EOF

    sudo mv api-to-kubelet-clusterrole.yaml $DEST
}

init_api_to_kubelet_clusterrolebinding()
{
    DEST=$1

    cat <<EOF | sudo tee api-to-kubelet-clusterrolebinding.yaml
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: system:kube-apiserver
      namespace: ""
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: system:kube-apiserver-to-kubelet
    subjects:
      - apiGroup: rbac.authorization.k8s.io
        kind: User
        name: kube-apiserver
EOF
    sudo mv api-to-kubelet-clusterrolebinding.yaml $DEST
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