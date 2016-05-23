for SRV in ntpd flanneld docker kube-proxy kubelet;
do
    sudo systemctl start $SRV
    #sudo systemctl enable $SRV
    sudo systemctl status $SRV
done
