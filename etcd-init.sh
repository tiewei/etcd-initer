#!/bin/sh

set -euo pipefail

: ${ETCD_INIT_LISTEN_PROTOCOL:=http}
: ${ETCD_INIT_LISTEN_PEER_PROTOCOL:=http}
: ${ETCD_INIT_LISTEN_LOCALHOST_PROTOCOL:="$ETCD_INIT_LISTEN_PROTOCOL"}
: ${ETCD_INIT_LISTEN_LOCALHOST_PORT:="$ETCD_INIT_LISTEN_PORT"}
: ${ETCD_INIT_LISTEN_ON_LOCALHOST:=1}

EXTRA_LISTEN=
if [ "$ETCD_INIT_LISTEN_ON_LOCALHOST" = "1" ]
then
    EXTRA_LISTEN=",${ETCD_INIT_LISTEN_LOCALHOST_PROTOCOL}://127.0.0.1:$ETCD_INIT_LISTEN_LOCALHOST_PORT"
fi

IFS=,
for LINE in $ETCD_INIT_CLUSTER; do
    NAME=$(echo "$LINE" | awk -F'[=/:]' '{print $1}')
    IP=$(echo "$LINE" | awk -F'[=/:]' '{print $5}')
    if ip addr show | grep -qF "inet $IP/"; then
        echo "Using IP=$IP, NAME=$NAME."
        cat > "$ETCD_INIT_ARGSFILE" <<EOF
--name $NAME \
--initial-advertise-peer-urls $ETCD_INIT_LISTEN_PEER_PROTOCOL://$IP:$ETCD_INIT_PEER_PORT \
--listen-peer-urls $ETCD_INIT_LISTEN_PEER_PROTOCOL://$IP:$ETCD_INIT_PEER_PORT \
--advertise-client-urls $ETCD_INIT_LISTEN_PROTOCOL://$IP:$ETCD_INIT_LISTEN_PORT \
--listen-client-urls $ETCD_INIT_LISTEN_PROTOCOL://$IP:$ETCD_INIT_LISTEN_PORT$EXTRA_LISTEN \
--initial-cluster $ETCD_INIT_CLUSTER \
--data-dir $ETCD_INIT_DATA_DIR
EOF
        exit 0
    fi
done

echo "Error: Could not find any of my IPs in ETCD_INIT_CLUSTER=$ETCD_INIT_CLUSTER" >&2
exit 1
