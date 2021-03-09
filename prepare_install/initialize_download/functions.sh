download_component()
{
    NAME=$1
    VERSION=$2
    DEST=$3

    wget -q --show-progress --https-only --timestamping \
        "https://storage.googleapis.com/kubernetes-release/release/v$VERSION/bin/linux/amd64/$NAME" -P $DEST
    
    chmod +x $DEST/$NAME
}

download_and_extract_etcd()
{
    VERSION=$1
    DEST=$2

    wget -q --show-progress --https-only --timestamping \
        "https://github.com/coreos/etcd/releases/download/v$VERSION/etcd-v$VERSION-linux-amd64.tar.gz"

    sudo tar -xvf etcd-v$VERSION-linux-amd64.tar.gz
    sudo mv etcd-v$VERSION-linux-amd64/etcd* $DEST
    sudo rm -r etcd*
}

download_and_extract_cni()
{
    VERSION=$1
    DEST=$2

    wget https://github.com/containernetworking/plugins/releases/download/v$VERSION/cni-plugins-amd64-v$VERSION.tgz

    sudo tar -xzvf cni-plugins-amd64-v$VERSION.tgz --directory $DEST
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