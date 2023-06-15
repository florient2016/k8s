#!/bin/bash

#sudo hostnamectl set-hostname control
sudo yum install python3  -y
sudo pip3 install ansible

echo this script is now deprecated and provided for compatibility reasons only.


sudo yum install -y vim git bash-completion wget tmux


git clone https://github.com/sandervanvugt/cka.git

git clone https://github.com/sandervanvugt/ckad.git
#kubeadm join 172.31.4.133:6443 --token fp513o.ycsgdtzszk6jy15q --discovery-token-ca-cert-hash sha256:5b5471d87ccba9faff4e49ea99124b248ebfac9772621c2ec9502251d8cde9f8
sudo yum install -y vim yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# notice that only verified versions of Docker may be installed
# verify the documentation to check if a more recent version is available

#sudo yum install -y docker-ce
#sudo yum install podman-docker -y
[ ! -d /etc/docker ] && mkdir /etc/docker

sudo cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF


sudo mkdir -p /etc/systemd/system/docker.service.d

sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker



sudo cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

	# disable swap (assuming that the name is /dev/centos/swap
	#sed -i 's/^\/dev\/mapper\/centos-swap/#\/dev\/mapper\/centos-swap/' /etc/fstab
sudo swapoff -a

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet

# Set iptables bridging
sudo cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system



sudo curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest \
  | grep browser_download_url \
  | grep linux-amd64 \
  | cut -d '"' -f 4 \
  | wget -i -

sudo tar xvf etcd-v*.tar.gz

sudo cd etcd-*/
sudo mv etcd* /usr/local/bin/

sudo groupadd docker
sudo usermod -aG docker ec2-user

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm repo add stable https://charts.helm.sh/stable

sudo yum install -y httpd
sudo systemctl start  httpd

#Install pre requisite for openshift
sudo yum install -y qemu-kvm*
sudo yum group -y install --with-optional virtualization-host-environment
sudo systemctl enable --now libvirtd
grep libvirt /etc/group
sudo usermod -a -G libvirt ec2-user
newgrp - libvirt
groups

curl --location https://github.com/docker/machine/releases/download/v0.16.1/docker-machine-Linux-`uname -i` > docker-machine
sudo chmod +x docker-machine
sudo mv docker-machine /usr/local/bin/
curl --location https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.10.0/docker-machine-driver-kvm-centos7 > docker-machine-driver-kvm
sudo chmod +x docker-machine-driver-kvm
sudo mv docker-machine-driver-kvm /usr/local/bin/
wget -qO- https://github.com/minishift/minishift/releases/download/v1.34.0/minishift-1.34.0-linux-amd64.tgz | tar --extract --gzip --verbose -C ~/

#install minishift for openshift
#wget https://github.com/minishift/minishift/releases/download/v1.34.3/minishift-1.34.3-linux-amd64.tgz
#tar xvzf minishift-1.34.3-linux-amd64.tgz
#sudo kubeadm init > /home/ec2-user/kubeadm.txt
#sleep 30
#mkdir -p $HOME/.kube
#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo rm -rf /etc/containerd/config.toml
sudo systemctl restart containerd
#sudo kubeadm init

sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
#kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/calico.yaml

#autocmd FileType yaml setlocal ai ts=2 sw=2 et
#kubeadm join 172.31.0.137:6443 --token g9wzjb.jiirr41gu383bj33 --discovery-token-ca-cert-hash sha256:fdac13fcfbc783699fec9b23ad8bef7e7351c941b02a26cd76b4c7774c08a7c0

#Install K9s for monitoring your cluster
#sudo yum install go make -y
#curl -sS https://webinstall.dev/k9s | bash