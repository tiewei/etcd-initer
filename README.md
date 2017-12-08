## etcd-initer

This `etcd-initer` is a simple k8s init container used for etcd cluster.
It creates an etcd starting args from its environment variables

# Why need etcd-initer

In most of time, when creating a etcd cluster, we know the ip or DNS name of
members in cluster, peer and listen ports, and mostly importantly we usually
give each member a name. All of these data can be formed as `--initial-cluster`
parameter for etcd to start. In k8s deployment though, no matter it's a
`replicasets` or a `daemonsets`, there's no easy way to create one single
config file that could determine the mapping between ip and name we wanted
to assign to a etcd member. Upstream etcd gave [an example](https://github.com/coreos/etcd/blob/master/hack/kubernetes-deploy/etcd.yml)
shows deploying in k8s by creating 3 individual pod and make them listen on
all ips, this is not going to scale.

# What is etcd-initer

`etcd-initer` is a container designed to be used as init container for
etcd members, it based on `busybox` and a simple shell script to generate a etcd args
file, and the file can be used for starting etcd cluster. Below is a typical usage
of `etcd-initer` container as part of `daemonset` and using host network:

```
initContainers:
- name: etcd-init
  image: ferest/etcd-initer:latest
  env:
    - name: ETCD_INIT_ARGSFILE
      value: /etc/etcd/etcd-args
    - name: ETCD_INIT_LISTEN_PORT
      value: 2379
    - name: ETCD_INIT_PEER_PORT
      value: 2380
    - name: ETCD_INITIAL_CLUSTER
      value: etcd0=http://192.168.1.3:2380,etcd1=http://192.168.1.4:2380,etcd2=http://192.168.1.5:2380
    - name: ETCD_INIT_DATA_DIR
      value: /var/lib/etcd/
  volumeMounts:
    - name: etcd-conf-dir
      mountPath: /etc/etcd/
containers:
- name: etcd-node
  image: quay.io/coreos/etcd:v3.2.4
  command: ["sh", "-c"]
  args:
    - /usr/local/bin/etcd
    - "$(cat $ETCD_INIT_ARGSFILE)"
  env:
    - name: ETCD_INIT_ARGSFILE
      value: /etc/etcd/etcd-args
  volumeMounts:
    - name: etcd-conf-dir
      mountPath: /etc/etcd/
    - name: etcd-data-dir
      mountPath: /var/lib/etcd/
volumes:
- name: etcd-data-dir
  hostPath:
    path: /var/lib/etcd/
- name: etcd-conf-dir
  hostPath:
    path: /etc/etcd/
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# Licence

MIT.
