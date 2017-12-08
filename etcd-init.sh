#!/bin/sh

for line in $(echo $ETCD_INIT_CLUSTER | tr ',' '\n'); do
    echo $line | awk  -F'[=/:]' '{print $1,$5}' | {
        read -r  name myip
        if ip addr show | grep -q $myip &> /dev/null ; then
            cat > $ETCD_INIT_ARGSFILE <<EOF
--name $name --initial-advertise-peer-urls http://$myip:$ETCD_INIT_PEER_PORT \
--listen-peer-urls http://$myip:$ETCD_INIT_PEER_PORT \
--advertise-client-urls http://$myip:$ETCD_INIT_LISTEN_PORT \
--listen-client-urls http://$myip:$ETCD_INIT_LISTEN_PORT,http://127.0.0.1:$ETCD_INIT_LISTEN_PORT \
--initial-cluster $ETCD_INIT_CLUSTER \
--data-dir $ETCD_INIT_DATA_DIR
EOF
        fi
    }
done
