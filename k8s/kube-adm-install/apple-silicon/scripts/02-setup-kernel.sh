#!/usr/bin/env bash

# Definir colores para la salida de terminal
YELLOW="\033[1;33m"
NC="\033[0m"

# Mostrar un mensaje decorativo
#echo -e "${YELLOW}   _${NC}"
#echo -e "${YELLOW} ('v')${NC}"
#echo -e "${YELLOW}//-=-\\${NC}"
#echo -e "${YELLOW}(\_=_/)${NC}"
#echo -e "${YELLOW} ^^ ^^${NC}"
echo -e "${YELLOW}.........${NC}"
echo -e "${YELLOW}...............${NC}"
echo -e "${YELLOW}........................${NC}"
echo -e "${YELLOW}....................................${NC}"
echo -e "${YELLOW}................................................${NC}"

# Cargar los módulos del kernel necesarios
echo -e "${YELLOW}Cargando módulos del kernel necesarios...${NC}"
sudo modprobe overlay
sudo modprobe br_netfilter

# Hacer que los módulos se carguen automáticamente al inicio
echo -e "${YELLOW}Haciendo persistentes los módulos del kernel...${NC}"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Configurar los parámetros de red necesarios para Kubernetes
echo -e "${YELLOW}Configurando parámetros de red...${NC}"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Aplicar los parámetros de red sin necesidad de reiniciar
echo -e "${YELLOW}Aplicando parámetros de red...${NC}"
sudo sysctl --system

echo -e "${YELLOW}Configuración de los requisitos previos del sistema operativo completada.${NC}"

#cat <<EOF | kubectl apply -f -
#apiVersion: v1
#kind: ServiceAccount
#metadata:
#  name: dashboard-admin
#  namespace: kubernetes-dashboard
#EOF