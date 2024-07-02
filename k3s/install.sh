#!/usr/bin/env bash
set -euo pipefail

# Colores para la salida de terminal
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"

# Configuración de variables
NUM_WORKER_NODES=${1:-2}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para mostrar uso del script
usage() {
    echo "Usage: $0 <number_of_nodes>"
    exit 1
}

# Verificar argumentos
if [ $# -lt 1 ]; then
    usage
fi

# Verificar si Multipass está instalado
if ! command_exists multipass; then
    echo -e "${RED}'multipass' not found. Please install it${NC}"
    echo "https://multipass.run/install"
    exit 1
fi

# Verificar la disponibilidad de memoria
MEM_GB=$(( $(sysctl hw.memsize | cut -d ' ' -f 2) / 1073741824 ))

if [ $MEM_GB -t 8 ]; then
    echo -e "${RED}System RAM is ${MEM_GB}GB. This is insufficient to deploy a working cluster.${NC}"
    exit 1
fi

# Si los nodos están en funcionamiento, reiniciarlos
if multipass list --format json | jq -r '.list[].name' | grep -E '(k3s-control-plane|k3s-worker-node[0-9]+)' > /dev/null; then
    echo -n -e $RED
    read -p "VMs are running. Stop, delete and rebuild them (y/n)? " ans
    echo -n -e $NC
    [ "$ans" != 'y' ] && exit 1
fi

workers=$(for n in $(seq 1 $NUM_WORKER_NODES); do echo -n "k8s-worker-node$n "; done)
echo "We will proceed to create k8s-control-plane with these nodes: ${workers}"

for node in k3s-control-plane $workers; do
    if multipass list --format json | jq -r '.list[].name' | grep "$node"; then
        echo -e "${YELLOW}Deleting $node${NC}"
        multipass delete $node
        multipass purge
    fi

#    echo -e "${BLUE}Launching ${node}${NC}"
#    if [ "$node" = "k8s-control-plane" ]; then
#        if ! multipass launch $bridge_arg --disk 20G --memory $MASTER_MEMORY --cpus 4 --name $node jammy; then
#            sleep 1
#        fi
#    else
#        if ! multipass launch $bridge_arg --disk 20G --memory $WORKERS_MEMORY --cpus 4 --name $node jammy; then
#            sleep 1
#        fi
#    fi
#
#    if [ "$(multipass list --format json | jq -r --arg no $node '.list[] | select(.name == $no) | .state')" != "Running" ]; then
#        echo -e "${RED}$node failed to start!${NC}"
#        exit 1
#    fi
#    echo -e "${GREEN}$node booted!${NC}"
done

multipass launch --disk 20G --memory 2G --cpus 4 --name k3s-control-plane jammy;


for f in 1 2; do
     multipass launch -c 1 -m 1G -d 4G -n k3s-worker-$f 18.04
 done

 multipass exec k3s-master -- bash -c "curl -sfL https://get.k3s.io | sh -"

 TOKEN=$(multipass exec k3s-master sudo cat /var/lib/rancher/k3s/server/node-token)
IP=$(multipass info k3s-master | grep IPv4 | awk '{print $2}')


for f in 1 2; do
     multipass exec k3s-worker-$f -- bash -c "curl -sfL https://get.k3s.io | K3S_URL=\"https://$IP:6443\" K3S_TOKEN=\"$TOKEN\" sh -"
 done

 multipass exec k3s-master -- bash

