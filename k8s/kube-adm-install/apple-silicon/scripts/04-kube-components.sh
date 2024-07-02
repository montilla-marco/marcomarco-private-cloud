#!/usr/bin/env bash
# Definir colores para la salida de terminal
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
NC="\033[0m"

echo -e "${YELLOW}                                 88${NC}"
echo -e "${YELLOW}                                 88${NC}"
echo -e "${YELLOW}                                 88${NC}"
echo -e "${YELLOW}8b,dPPYba,   ,adPPYba,   ,adPPYb,88${NC}"
echo -e "${YELLOW}88P\'    "8a a8"     "8a a8"    \`Y88${NC}"
echo -e "${YELLOW}88       d8 8b       d8 8b       88${NC}"
echo -e "${YELLOW}88b,   ,a8\" \"8a,   ,a8\" \"8a,   ,d88${NC}"
echo -e "${YELLOW}88\`YbbdP\"\'   \`\"YbbdP\"\'   \`\"8bbdP\"Y8${NC}"
echo -e "${YELLOW}88${NC}"
echo -e "${YELLOW}88${NC}"

# Obtener la última versión estable de Kubernetes
KUBE_LATEST=$(curl -L -s https://dl.k8s.io/release/stable.txt | awk 'BEGIN { FS="." } { printf "%s.%s", $1, $2 }')

echo -e "${YELLOW}pulling from kubernetes.list.....${NC}"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo bash -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes main
EOF'


echo -e "${BLUE}Configuring kubernetes repository...${NC}"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo -e "${BLUE}Updating package manager of ubuntu system.....${NC}"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

echo -e "${BLUE}Installing k8s components kubeadm, kubelet y kubectl kubernetes-cni ...${NC}"
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
sudo apt-mark hold kubelet kubeadm kubectl


echo -e "${BLUE}Configuring crictl for containerd integration...${NC}"
sudo crictl config \
    --set runtime-endpoint=unix:///run/containerd/containerd.sock \
    --set image-endpoint=unix:///run/containerd/containerd.sock

# Obtener la IP primaria del nodo
PRIMARY_IP=$(ip route get 8.8.8.8 | awk 'NR==1 {print $7}')
echo -e "${BLUE}Primary ip address of this machine $PRIMARY_IP${NC}"

echo -e "${BLUE}Configuring kubelet with machine ip address...${NC}"
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS='--node-ip=${PRIMARY_IP}'
EOF

#echo -e "${BLUE}Restarting kubelet...${NC}"
#sudo systemctl daemon-reload
#sudo systemctl restart kubelet
#
#kubelet_config=$(cat /etc/kubernetes/kubelet.conf)
#echo -e "${YELLOW}The kubelet config file is $kubelet_config${NC}"
echo -e "${BLUE}Kubernetes installation and configuration accomplish!!${NC}"




