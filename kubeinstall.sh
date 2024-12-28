sudo setenforce 0
sleep 3

sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux

sleep 3

sestatus

sleep 3

sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10259/tcp
sudo firewall-cmd --permanent --add-port=10257/tcp
sudo firewall-cmd --permanent --add-port=179/tcp
sudo firewall-cmd --permanent --add-port=4789/udp

sudo firewall-cmd --reload

sleep 3

sudo hostnamectl k8s.nalba.online
sleep 3

echo "127.0.0.1 k8s.nalba.online" | sudo tee -a /etc/fstab


sleep 3
swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

sleep 3
sudo yum update
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sleep 3

sudo yum install -y docker-ce docker-ce-cli containerd.io --allowerasing
sudo systemctl enable docker
sudo systemctl start docker

sleep 3
echo '{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}' | sudo tee /etc/docker/daemon.json > /dev/null


sleep 3

sudo systemctl daemon-reload
sudo systemctl restart docker

sleep 3
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.16/cri-dockerd-0.3.16.amd64.tgz
tar xvf cri-dockerd-0.3.16.amd64.tgz
sleep 3
sudo mv cri-dockerd/cri-dockerd /usr/local/bin/
cri-dockerd --version
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
sleep 3

sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
sleep 3
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
sudo systemctl daemon-reload
sleep 3
sudo systemctl enable cri-docker.service
sleep 3
sudo systemctl enable --now cri-docker.socket

sleep 3

sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

sleep 3

sudo dnf install kubeadm kubelet kubectl --disableexcludes=kubernetes

sleep 3
sleep 3
sleep 3
sleep 3
sleep 3
sleep 3
