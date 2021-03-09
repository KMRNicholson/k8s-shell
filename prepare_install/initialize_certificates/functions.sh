#Creates a self-signed certificate with a paired private key.
init_ca_crt_key_pair()
{
    CA=$1
    KEY_DEST=$2
    CERT_DEST=$3
    DAYS=$4
    
    KEY=$KEY_DEST/$CA.key
    CRT=$CERT_DEST/$CA.crt
    CSR=$CA.csr

    sudo openssl genrsa -out $KEY 2048
    sudo openssl req -new -key $KEY -subj "/CN=KUBERNETES-CA" -out $CSR
    sudo openssl x509 -req -in $CSR -signkey $KEY -CAcreateserial \
        -days $DAYS -out $CRT

    sudo rm $CSR
}

#Signs a csr using the ca key and generates a private key for a component.
init_component_crt_key_pair()
{
    CA=$1
    COMPONENT=$2
    CERT_DEST=$3
    KEY_DEST=$4
    DAYS=$5
    CONF=$6

    CSR=$COMPONENT.csr
    CRT=$CERT_DEST/$COMPONENT.crt

    CA_CRT=$CERT_DEST/$CA.crt
    CA_KEY=$KEY_DEST/$CA.key

    #This will generate a new private key and csr based on openssl.cnf
    sudo openssl req -new -config $CONF -out $CSR

    sudo openssl x509 -req -in $CSR -CA $CA_CRT -CAkey $CA_KEY \
        -days $DAYS -extensions v3_req -extfile $CONF -out $CRT -CAcreateserial

    #Remove the csr as it is no longer needed
    sudo rm $CSR

    #Move the private key to the key directory
    sudo mv $COMPONENT.key $KEY_DEST

    #Write certificate information to console
    sudo openssl x509 -in $CRT -noout -text
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