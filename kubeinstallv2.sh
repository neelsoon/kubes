## Using wget to download and execute the script in one command
#wget -qO- https://raw.githubusercontent.com/neelsoon/kubes/main/kubeinstallv2.sh | bash
#https://phoenixnap.com/kb/calico-kubernetes
#mac 52:54:00:5C:AA:69	
# 
sudo setenforce 0
sleep 1.5

sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux

sleep 1.5

sestatus

sleep 1.5

sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10259/tcp
sudo firewall-cmd --permanent --add-port=10257/tcp
sudo firewall-cmd --permanent --add-port=179/tcp
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --permanent --add-port=4789/udp

sudo firewall-cmd --reload

sleep 1.5

hostnamectl hostname k8s.nalba.online
sleep 1.5

echo "127.0.0.1 k8s.nalba.online" | sudo tee -a /etc/fstab


sleep 1.5
swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

sleep 1.5
sudo yum update -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sleep 1.5

sudo yum install -y docker-ce docker-ce-cli containerd.io --allowerasing
sudo systemctl enable docker
sudo systemctl start docker

sleep 1.5
echo '{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}' | sudo tee /etc/docker/daemon.json > /dev/null


sleep 1.5

sudo systemctl daemon-reload
sudo systemctl restart docker

sleep 1.5
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.16/cri-dockerd-0.3.16.amd64.tgz
tar xvf cri-dockerd-0.3.16.amd64.tgz
sleep 1.5
sudo mv cri-dockerd/cri-dockerd /usr/local/bin/
cri-dockerd --version
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
sleep 1.5

sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
sleep 1.5
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
sudo systemctl daemon-reload
sleep 1.5
sudo systemctl enable cri-docker.service
sleep 1.5
sudo systemctl enable --now cri-docker.socket

sleep 1.5

sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

sleep 1.5

sudo dnf install  -y kubeadm kubelet kubectl --disableexcludes=kubernetes

sleep 1.5
sudo systemctl enable kubelet
sudo systemctl start kubelet

sleep 1.5
tee /etc/modules-load.d/containerd.conf <<EOF
br_netfilter
EOF
modprobe br_netfilter

tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sleep 1.5
sudo kubeadm init --cri-socket /run/cri-dockerd.sock
sleep 1.5
sleep 1.5
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sleep 1.5
#kubectl taint nodes --all node-role.kubernetes.io/control-plane-

kubectl get nodes
sleep 1.5

sleep 1.5


sleep 1.5
sleep 1.5 
