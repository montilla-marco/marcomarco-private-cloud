#!/usr/bin/env bash

set -euo pipefail

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}


# Función para mostrar uso del script
usage() {
    echo "Usage: $0 <number_of_nodes> [-auto] [bridge | nat]"
    exit 1
}

# Configuración de variables
NUM_WORKER_NODES=${1:-2}
ISAUTO=${2:-false}
BUILD_MODE=${3:-BRIDGE}

MASTER_MEMORY="2G"
WORKERS_MEMORY="8G"

# Colores para la salida de terminal
RED="\033[1;31m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
NC="\033[0m"


# Verificar argumentos
if [ $# -lt 1 ]; then
    usage
fi

if [ $# -lt 3 ]; then
    BUILD_MODE="BRIDGE"
    echo "The networking model will be by default $BUILD_MODE"
fi

if [ $NUM_WORKER_NODES -lt 1 ]; then
    echo -e "${RED}Thje number of worker nodes has to be at least 1.${NC}"
    exit 1
fi

# Verificar si Multipass está instalado
if ! command_exists multipass; then
    echo -e "${RED}'multipass' not found. Please install it${NC}"
    echo "https://multipass.run/install"
    exit 1
fi

# Verificar si jq está instalado
if ! command_exists jq; then
    echo -e "${RED}'jq' not found. Please install it${NC}"
    echo "https://github.com/stedolan/jq/wiki/Installation#macos"
    exit 1
fi

# Verificar la disponibilidad de memoria
MEM_GB=$(( $(sysctl hw.memsize | cut -d ' ' -f 2) / 1073741824 ))

if [ $MEM_GB -t 18 ]; then
    echo -e "${RED}System RAM is ${MEM_GB}GB. This is insufficient to deploy a working cluster.${NC}"
    exit 1
fi

workers=$(for n in $(seq 1 $NUM_WORKER_NODES); do echo -n "k8s-worker-node$n "; done)
echo "We will proceed to create k8s-control-plane with these nodes: ${workers}"

# Determinar interfaz para bridge
interface=""
bridge_arg="--bridged"

for iface in $(multipass networks --format json | jq -r '.list[] | .name'); do
    if netstat -rn -f inet | grep "^default.*${iface}" > /dev/null; then
        interface=$iface
        echo "The platform will use the following network interface: $iface"
        break
    fi
done

if [ "$(multipass get local.bridged-network)" = "<empty>" ]; then
    echo -e "${BLUE}Configuring bridge network...${NC}"

    if [ -z "${interface}" ]; then
        echo -e "${YELLOW}No suitable interface detected to use as bridge"
        echo "Falling back to NAT installation"
        echo -e "You will not be able to use your browser to connect to NodePort services.${NC}"
        BUILD_MODE="NAT"
        bridge_arg=""
    else
        echo -e "${GREEN}Configuring bridge to interface '$(multipass networks | grep ${interface})'${NC}"
        multipass set local.bridged-network=${interface}
    fi
fi

# Si los nodos están en funcionamiento, reiniciarlos
if multipass list --format json | jq -r '.list[].name' | grep -E '(k8s-control-plane|k8s-worker-node[0-9]+)' > /dev/null; then
    echo -n -e $RED
    read -p "VMs are running. Stop, delete and rebuild them (y/n)? " ans
    echo -n -e $NC
    [ "$ans" != 'y' ] && exit 1
fi

for node in k8s-control-plane $workers; do
    if multipass list --format json | jq -r '.list[].name' | grep "$node"; then
        echo -e "${YELLOW}Deleting $node${NC}"
        multipass delete $node
        multipass purge
    fi

    echo -e "${BLUE}Launching ${node}${NC}"
    if [ "$node" = "k8s-control-plane" ]; then
        if ! multipass launch $bridge_arg --disk 20G --memory $MASTER_MEMORY --cpus 4 --name $node jammy; then
            sleep 1
        fi
    else
        if ! multipass launch $bridge_arg --disk 40G --memory $WORKERS_MEMORY --cpus 8 --name $node jammy; then
            sleep 1
        fi
    fi

    if [ "$(multipass list --format json | jq -r --arg no $node '.list[] | select(.name == $no) | .state')" != "Running" ]; then
        echo -e "${RED}$node failed to start!${NC}"
        exit 1
    fi
    echo -e "${GREEN}$node booted!${NC}"
done

# Create hostfile entries
echo -e "${BLUE}Setting hostnames${NC}"
hostentries=/tmp/hostentries
set -x
network=$(netstat -rn -f inet | grep "^default.*${interface}" | awk '{print $2}' | awk 'BEGIN { FS="." } { printf "%s.%s.%s", $1, $2, $3 }')
[ -f $hostentries ] && rm -f $hostentries

for node in k8s-control-plane $workers
do
    if [ "$BUILD_MODE" = "BRIDGE" ]
    then
        ip=$(multipass info $node --format json | jq -r --arg nw $network 'first( .info[] )| .ipv4  | .[] | select(startswith($nw))')
    else
        ip=$(multipass info $node --format json | jq -r 'first( .info[] | .ipv4[0] )')
    fi
    echo "$ip $node" >> $hostentries
done

echo -e "${BLUE}configuring the following ip address for each machine ${NC}"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/scripts
for node in k8s-control-plane $workers
do
    multipass transfer $hostentries $node:/tmp/
    multipass transfer $SCRIPT_DIR/01-setup-hosts.sh $node:/tmp/
    multipass exec $node -- /tmp/01-setup-hosts.sh $BUILD_MODE $network
done
echo -e "${GREEN}Done!${NC}"

if [ "$ISAUTO" = "-auto" ]
then
    # Set up hosts
    echo -e "${YELLOW}Setting up common components${NC}"

    join_command=/tmp/join-command.sh

    for node in k8s-control-plane $workers
    do
        echo -e "${BLUE}- ${node}${NC}"
        multipass transfer $hostentries $node:/tmp/
        multipass transfer $SCRIPT_DIR/*.sh $node:/tmp/
        for script in 02-setup-kernel.sh 03-setup-cri.sh 04-kube-components.sh
        do
            multipass exec $node -- /tmp/$script
        done
    done

    echo -e "${YELLOW}Done!${NC}"

    #Configure control plane
    echo -e "${BLUE}Setting up control plane${NC}"
    multipass exec k8s-control-plane /tmp/05-deploy-controlplane.sh
    multipass transfer k8s-control-plane:/tmp/join-command.sh $join_command
    echo -e "${YELLOW}Done!${NC}"

    # Configure workers
    for n in $workers
    do
        echo -e "${BLUE}Setting up the worker with join command${n}${NC}"
        multipass transfer $join_command $n:/tmp
        multipass exec $n -- sudo $join_command
        echo -e "${YELLOW}Done!${NC}"
    done
fi

echo -e "${GREEN}Kubernetes cluster setup is complete!${NC}"
echo -e "${BLUE}Happy k8s hacking!!!"
