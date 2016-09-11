for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler; do
    systemctl status $SERVICES
done
