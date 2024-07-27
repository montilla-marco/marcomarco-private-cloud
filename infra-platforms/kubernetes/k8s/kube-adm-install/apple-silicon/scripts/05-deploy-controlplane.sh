#!/usr/bin/env bash

# Definir colores para la salida de terminal
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
PURPLE="\[\033[1;35m\]"
NC="\033[0m"

# Definir variables de red
POD_CIDR=10.244.0.0/16
SERVICE_CIDR=10.96.0.0/16

# Obtener la dirección IP del nodo
ip=$(ip route get 8.8.8.8 | awk 'NR==1 {print $7}')
echo -e "${YELLOW}IP address obtained: $ip${NC}"

# Eliminar cualquier versión anterior de la imagen de la sandbox
sudo ctr images rm registry.k8s.io/pause:3.8 || true

#echo -e "${BLUE}Upgrading kubeadm node${NC}"
#sudo kubeadm alpha kubeconfig user --org system:nodes --kubeconfig /etc/kubernetes/kubelet.conf
#kubeadm upgrade node

# Asegurarse de que la imagen de la sandbox de contenedores es la correcta
echo -e "${BLUE}Pulling the correct pause image${NC}"
sudo ctr images pull registry.k8s.io/pause:3.9

# Inicializar el plano de control
echo -e "${BLUE}Proceeding to initialize the control plane on IP address: $ip${NC}"
sudo kubeadm init --pod-network-cidr=$POD_CIDR --service-cidr=$SERVICE_CIDR --apiserver-advertise-address=$ip #--cri-socket=unix:///run/containerd/containerd.sock --image-repository=registry.k8s.io

# Configurar kubectl para el usuario no root
echo -e "${BLUE}Setting up kubeconfig for the current user${NC}"
mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config

## Renombrar el contexto, usuario y cluster
#echo -e "${BLUE}Renaming context, user, and cluster${NC}"
#kubectl config rename-context kubernetes-admin@kubernetes k8s-context
#
## Cambiar el nombre del usuario en el archivo kubeconfig
#kubectl config set-credentials k8s-marcomarco --client-certificate=$(kubectl config view -o jsonpath='{.users[0].user.client-certificate}') --client-key=$(kubectl config view -o jsonpath='{.users[0].user.client-key}')
#
## Cambiar el nombre del cluster en el archivo kubeconfig
#kubectl config set-cluster k8s-cluster --server=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}') --certificate-authority=$(kubectl config view -o jsonpath='{.clusters[0].cluster.certificate-authority}')
#
## Actualizar el contexto para usar el nuevo usuario y cluster
#kubectl config set-context k8s-context --cluster=k8s-cluster --user=k8s-marcomarco
#
#cluster_info=$(kubectl cluster-info dump)
#echo -e "${PURPLE}Dumping cluster infor $cluster_info${NC}"
#
#cluster_contexts=$(kubectl config get-contexts)
#echo -e "${PURPLE}Cluster contexts $cluster_contexts${NC}"
#
#cluster_users=$(kubectl config view -o jsonpath='{.users[*].name}')
#echo -e "${PURPLE}Cluster users $cluster_users${NC}"
#
#cluster_names=$(kubectl config view -o jsonpath='{.clusters[*].name}')
#echo -e "${PURPLE}Cluster nanes $cluster_names${NC}"

# Instalar weaveworks como complemento de red de pods
#kubectl apply -f "https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml"

# Instalar Flannel como complemento de red de pods
echo -e "${BLUE}Installing Flannel for pod networking${NC}"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Crear el comando de unión y guardarlo en un archivo
echo -e "${BLUE}Creating join command for worker nodes${NC}"
sudo kubeadm token create --print-join-command | sudo tee /tmp/join-command.sh > /dev/null
sudo chmod +x /tmp/join-command.sh

# Mostrar el comando de unión
cat /tmp/join-command.sh

# Esperar a que todos los pods del plano de control estén en ejecución
echo -e "${BLUE}Waiting for all control plane pods to be running${NC}"
for s in $(seq 60 -10 10); do
    echo "Waiting $s seconds..."
    sleep 10
done

echo -e "${BLUE}Getting pods status fron kube-system namespace${NC}"
kubectl get pods -n kube-system

echo -e "${GREEN}Kubernetes control plane setup complete!${NC}"
