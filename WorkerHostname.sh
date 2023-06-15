#!/bin/bash
#sudo hostnamectl set-hostname worker-${Number}

echo this script is now deprecated and provided for compatibility reasons only.


sudo yum install -y vim git bash-completion wget tmux
sudo yum install -y vim yum-utils device-mapper-persistent-data lvm2 go
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo


# notice that only verified versions of Docker may be installed
# verify the documentation to check if a more recent version is available

sudo yum install docker-ce containerd.io -y
#sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
#sudo yum install -y docker-ce
#[ ! -d /etc/docker ] && mkdir /etc/docker

#sudo cat > /etc/docker/daemon.json <<EOF
#{
#  "exec-opts": ["native.cgroupdriver=systemd"],
#  "log-driver": "json-file",
#  "log-opts": {
#    "max-size": "100m"
#  },
#  "storage-driver": "overlay2",
#  "storage-opts": [
#    "overlay2.override_kernel_check=true"
#  ]
#}
#EOF


#sudo mkdir -p /etc/systemd/system/docker.service.d

sudo yum install docker-ce containerd.io -y
sudo rm -rf /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker


#echo RUNNING CENTOS CONFIG

# Set SELinux in permissive mode (effectively disabling it)
	# disable swap (assuming that the name is /dev/centos/swap
	#sed -i 's/^\/dev\/mapper\/centos-swap/#\/dev\/mapper\/centos-swap/' /etc/fstab
# Set iptables bridging
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system


sudo swapoff -a

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet

wget https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz
tar -xvf helm-v3.12.0-linux-amd64.tar.gz
cp linux-amd64/helm /usr/sbin/helm
cp linux-amd64/helm /usr/local/bin/helm



#sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
#kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/calico.yaml

#kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
#export PS1='$'

#https://github.com/istio/istio/releases/download/1.17.2/istio-1.17.2-linux-amd64.tar.gz

#kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml && \

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/tigera-operator.yaml
kubectl create -f  https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml

sudo sysctl --system

git clone https://github.com/sandervanvugt/cka.git

git clone https://github.com/sandervanvugt/ckad.git

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

