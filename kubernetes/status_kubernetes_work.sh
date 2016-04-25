for SERVICES in kube-proxy kubelet docker; do
    systemctl status $SERVICES
done
