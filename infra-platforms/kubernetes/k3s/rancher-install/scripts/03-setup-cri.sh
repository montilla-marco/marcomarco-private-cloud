#!/usr/bin/env bash

# Definir colores para la salida de terminal
BLUE="\033[1;34m"
GREEN="\033[1;32m"
NC="\033[0m"

RANCHER_DNS_NAME=$1

echo -e "${BLUE}Running script 03-setup-cri.sh.....................${NC}"
echo -e "${BLUE}Host name: $(hostname) ..................${NC}"
echo -e "${BLUE}RANCHER_DNS_NAME: $RANCHER_DNS_NAME ............${NC}"
echo -e "${BLUE}................................................${NC}"

echo -e "${BLUE}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀${NC}"
echo -e "${BLUE}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿${NC}"
echo -e "${BLUE}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠛⠛${NC}"
echo -e "${BLUE}⠀⠀⠀⠀⠀⠀⢰⣶⣶⣶⠀⣶⣶⣶⣶⠀⢰⣶⣶⣶${NC}"
echo -e "${BLUE}⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⣿⣿⣿⣿⠀⢸⣿⣿⣿${NC}"
echo -e "${BLUE}⠀⢠⣤⣤⣤⠀⢠⣤⣤⣤⠀⣤⣤⣤⣤⠀⢠⣤⣤⣤⠀⣰⣿⣿⣦.${NC}"
echo -e "${BLUE}⠀⢸⣿⣿⣿⠀⢸⣿⣿⣿⠀⣿⣿⣿⣿⠀⢸⣿⣿⣿⠀⣿⣿⠹⣿⣷⣀${NC}"
echo -e "${BLUE}⠀⠘⠛⠛⠛⠀⠘⠛⠛⠛⠀⠛⠛⠛⠛⠀⠘⠛⠛⠛⢀⣿⣿⡀⠙⠿⠿⣿⣶⣆${NC}"
echo -e "${BLUE}⣴⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣿⣿⣿⠟⢁⣤⣴⣶⣾⡿⠋${NC}"
echo -e "${BLUE}⣿⣿⣿⣛⣛⣛⣛⣿⣟⣛⣛⣻⣿⣟⣛⣛⣻⣿⣟⣋⣉⣠⣤⣾⣿⣟⣻⣍${NC}"
echo -e "${BLUE}⢹⣿⣿⣀⣀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⠋${NC}"
echo -e "${BLUE}⠈⢻⣿⣿⣿⡿⠿⠿⠿⠛⠉⠀⠀⠀⠀⠀⢀⣠⣴⣿⣿⣿⠟⠁${NC}"
echo -e "${BLUE}⠀⠀⠙⢿⣿⣿⣶⣦⣤⣤⣤⣤⣤⣴⣶⣿⣿⣿⣿⠟⠋⠁${NC}"
echo -e "${BLUE}⠀⠀⠀⠀⠈⠙⠛⠛⠿⠿⠿⠿⠿⠛⠛⠛⠉⠁${NC}"


# Instalar docker
echo -e "${BLUE}Installing container runtime docker...${NC}"
curl https://releases.rancher.com/install-docker/20.10.sh | sh && \
sudo usermod -aG docker ubuntu && \
sudo systemctl enable docker
echo -e "${GREEN}Docker installation ready and started!!!${NC}"


echo -e "${GREEN}Netplan configuration${NC}"
MY_ADDRESS_RANGE=$(ip addr | grep enp0s1 | grep inet | awk '{print $2}')
cd /etc/netplan/
sudo cat <<EOF >00-installer-config.yaml
network:
  version: 2
  ethernets:
    enp0s1:
      addresses:
        - $MY_ADDRESS_RANGE
      nameservers:
        addresses: [$RANCHER_DNS_NAME, 8.8.8.8]
        search: []
      routes:
        - to: default
          via: 192.168.0.1
EOF
sudo netplan apply
echo -e "${BLUE}$(cat 00-installer-config.yaml)${NC}"
echo -e "${BLUE}netplan applied!!!${NC}"
