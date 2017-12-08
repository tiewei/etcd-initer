FROM busybox:1.27

LABEL maintainer "Cisco Contiv (https://contiv.github.io)"

COPY etcd-init.sh /

ENTRYPOINT ["/etcd-init.sh"]
