for SRV in ntpd etcd kube-apiserver kube-scheduler kube-controller-manager;
do
    sudo systemctl start $SRV
    #sudo systemctl enable $SRV
    sudo systemctl status $SRV
done
