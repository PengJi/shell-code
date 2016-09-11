for SRV in ntpd flanneld docker kube-proxy kubelet;
do
    sudo systemctl stop $SRV
    #sudo systemctl enable $SRV
    sudo systemctl status $SRV
done
