for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler; do 
    #systemctl restart $SERVICES
    #systemctl enable $SERVICES
    systemctl start $SERVICES
    systemctl status $SERVICES 
done
