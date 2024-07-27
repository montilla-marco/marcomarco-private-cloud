#!/usr/bin/env bash
NETWORK=$1
HOST_NAME=$(hostname)

BLUE="\033[1;34m"
GREEN="\033[1;32m"
NC="\033[0m"

echo -e "${BLUE}Arguments passed to script 01-setup-hosts.sh.....${NC}"
echo -e "${BLUE}NETWORK: $NETWORK.......................${NC}"
echo -e "${BLUE}HOST_NAME: $HOST_NAME...................${NC}"
echo -e "${GREEN}................................................${NC}"

echo -e "${BLUE}Updating package manager of ubuntu system.....${NC}"
sudo apt-get update

echo -e "${BLUE}Setting hostfile entries.....${NC}"
cat /tmp/hostentries | sudo tee -a /etc/hosts
sudo cat /etc/hosts
echo -e "${GREEN}hostfile entries setted.....${NC}"

# Export internal IP of primary NIC as an environment variable
echo "PRIMARY_IP=$(ip route | grep "^default.*${NETWORK}" | awk '{ print $9 }')" | sudo tee -a /etc/environment > /dev/null
echo -e "${BLUE}PRIMARY_IP from etc entries.....${NC}"
sudo cat /etc/environment
echo -e "${BLUE}................................${NC}"

echo -e "${BLUE}Enable password auth in sshd so we can use ssh-copy-id${NC}"
sudo sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config
sudo sed -i 's/KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
echo -e "${GREEN}systemctl restart sshd.....${NC}"

# Set password for ubuntu user (it's something random by default)
echo 'ubuntu:ubuntu' | sudo chpasswd

echo -e "${BLUE}script 01-setup-hosts.sh executed BYE!!!!!.....${NC}"