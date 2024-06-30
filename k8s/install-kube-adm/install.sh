#!/usr/bin/env bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}
NUM_WORKER_NODES=$1
ISAUTO=$2
BUILD_MODE=$3

MASTER_MEMORY=2G
WORKERS_MEMORY=4G


set -euo pipefail

# Parse arguments for number of nodes
if [ $# -lt 1 ]; then
    echo "Usage: $0 <number_of_nodes> [-auto] [bridge (default) | nat]"
    exit 1
fi

# Parse arguments for number of nodes
if [ $# -lt 3 ]; then
    BUILD_MODE="BRIDGE"
    echo "The networking model will be by default $BUILD_MODE"
fi


# Set the build mode
# "BRIDGE" - Places VMs on your local network so cluster can be accessed from browser.
#            You must have enough spare IPs on your network for the cluster nodes.
# "NAT"    - Places VMs in a private virtual network. Cluster cannot be accessed
#            without setting up a port forwarding rule for every NodePort exposed.
#            Use this mode if for some reason BRIDGE doesn't work for you.


RED="\033[1;31m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
NC="\033[0m"

# Check if Multipass is installed
if ! command_exists multipass; then
    echo -e "${RED}'multipass' not found. Please install it${NC}"
    echo "https://multipass.run/install"
    exit 1
fi

# Check if jq is installed
if ! command_exists jq; then
    echo -e "${RED}'jq' not found. Please install it${NC}"
    echo "https://github.com/stedolan/jq/wiki/Installation#macos"
    exit 1
fi

# Check memory availability
MEM_GB=$(( $(sysctl hw.memsize | cut -d ' ' -f 2) /  1073741824 ))

if [ $MEM_GB -lt 6 ]
then
    echo -e "${RED}System RAM is ${MEM_GB}GB. This is insufficient to deploy a working cluster.${NC}"
    exit 1
fi

if [ $MEM_GB -lt 16 ]
then
    echo -e "${YELLOW}System RAM is ${MEM_GB}GB. Deploying only one worker node.${NC}"
    NUM_WORKER_NODES=1
    VM_MEM_GB=2G
    sleep 1
fi

workers=$(for n in $(seq 1 $NUM_WORKER_NODES) ; do echo -n "k8s-worker-node$n " ; done)
echo "We will proceed to create k8s-control-plane with this node(s): ${workers} "

# Determine interface for bridge
interface=""
bridge_arg="--bridged"

for iface in $(multipass networks --format json | jq -r '.list[] | .name')
do
    if netstat -rn -f inet | grep "^default.*${iface}" > /dev/null
    then
        interface=$iface
        echo "The platform will use the following network interface: $iface"
        break
    fi
done

if [ "$(multipass get local.bridged-network)" = "<empty>" ]
then
    echo -e "${BLUE}Configuring bridge network...${NC}"

    if [ -z "${interface}" ]
    then
        echo -e "${YELLOW}No suitable interface detected to use as bridge"
        echo "Falling back to NAT installation"
        echo -e "You will not be able to use your browser to connect to NodePort services.${NC}"
        BUILD_MODE="NAT"
        bridge_arg=""
    else
        # Set the bridge
        echo -e "${GREEN}Configuring bridge to interface '$(multipass networks | grep ${interface})'${NC}"
        multipass set local.bridged-network=${interface}
    fi
fi

# If the nodes are running, reset them
if multipass list --format json | jq -r '.list[].name' | egrep '(k8s-control-plane|k8s-worker-node1|k8s-worker-node2|k8s-worker-node3|k8s-worker-node4)' > /dev/null
then
    echo -n -e $RED
    read -p "VMs are running. stop, delete and rebuild them (y/n)? " ans
    echo -n -e $NC
    [ "$ans" != 'y' ] && exit 1
fi

for node in k8s-control-plane $workers
do
    if multipass list --format json | jq -r '.list[].name' | grep "$node"
    then
        echo -e "${YELLOW}Deleting $node${NC}"
        multipass delete $node
        multipass purge
    fi
    #control plane creation
    if [ $node = "k8s-control-plane" ]
    then
      echo -e "${BLUE}Launching ${node}${NC}"
      if ! multipass launch $bridge_arg --disk 5G --memory 2GB --cpus 4 --name $node jammy 2>/dev/null
      then
        sleep 1
      fi
    else
      echo -e "${BLUE}Launching ${node}${NC}"
      if ! multipass launch $bridge_arg --disk 30G --memory 4GB --cpus 4 --name $node jammy 2>/dev/null
      then
#        # Did it actually launch?
        sleep 1
        if [ "$(multipass list --format json | jq -r --arg no $node '.list[] | select (.name == $no) | .state')" != "Running" ]
        then
            echo -e "${RED}$node failed to start!${NC}"
            exit 1
        fi
      fi
    fi
    echo -e "${GREEN}$node booted!${NC}"
done

echo "happy k8s hacking!!!"