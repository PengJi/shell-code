for SERVICES in kube-proxy kubelet docker; do
    #systemctl restart $SERVICES
    #systemctl enable $SERVICES
    systemctl stop $SERVICES
done
