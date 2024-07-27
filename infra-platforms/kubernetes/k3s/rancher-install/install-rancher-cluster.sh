#!/usr/bin/env bash

set -euo pipefail

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}


# Función para mostrar uso del script
usage() {
    echo -e "${GREEN}Usage: $0 -volume-sharing=true|false${NC}"
    exit 1
}

# Configuración de variables
EXTRAS_MEMORY="2G"
RANCHERS_MEMORY="8G"
BUILD_MODE="BRIDGE"

# Colores para la salida de terminal
RED="\033[1;31m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
NC="\033[0m"

# Verificar si Multipass está instalado
echo -e "${YELLOW}Checking multipass..${NC}"
if ! command_exists multipass; then
    echo -e "${RED}'multipass' not found. Please install it${NC}"
    echo "https://multipass.run/install"
    exit 1
fi
echo -e "${PURPLE}Multipass installed${NC}"

# Verificar si jq está instalado
echo -e "${YELLOW}Checking jq..${NC}"
if ! command_exists jq; then
    echo -e "${RED}'jq' not found. Please install it${NC}"
    echo "https://github.com/stedolan/jq/wiki/Installation#macos"
    exit 1
fi
echo -e "${PURPLE}jq installed${NC}"

echo -e "${YELLOW}Checking volume sharing..${NC}"
if [ $# -lt 1 ]; then
    usage
fi

# Capturar el primer parámetro
VOLUME_SHARING_PARAM=$1
# Verificar que volume sharing sigue el formato esperado
if [[ ! "$VOLUME_SHARING_PARAM" =~ ^-volume-sharing=(true|false)$ ]]; then
  echo -e "${RED}Error: the value for param -volume-sharing must be -volume-sharing=true or -volume-sharing=false${NC}"
  usage
fi

# Extraer el valor de volume sharing
VOLUME_SHARING="${VOLUME_SHARING_PARAM#*=}"
if [ "$VOLUME_SHARING" == "true" ]; then
    echo -e "${GREEN}Volume sharing mode enabled.${NC}"
    LOCAL_VOLUMES_PATH="$HOME/volumes/"
    rm -Rf $LOCAL_VOLUMES_PATH
    mkdir $LOCAL_VOLUMES_PATH

    echo -e "${GREEN}By default, the directories will be created at $LOCAL_VOLUMES_PATH directory.${NC}"

    # Crear directorios para el nodo de control
    DIR_NAME="${LOCAL_VOLUMES_PATH}rancher-extras"
    mkdir -p "$DIR_NAME"
    chmod 777 "$DIR_NAME"

    DIR_NAME="${LOCAL_VOLUMES_PATH}rancher-control-plane"
    mkdir -p "$DIR_NAME"
    chmod 777 "$DIR_NAME"

    DIR_NAME="${LOCAL_VOLUMES_PATH}rancher-node1"
    mkdir -p "$DIR_NAME"
    chmod 777 "$DIR_NAME"

    VOLUME_MODE_CONTROL_PLANE=" --mount $DIR_NAME:/mnt/rancher-control-plane"
else
    echo -e "${PURPLE}Volume sharing is disabled there is going to be a data lost when shutdown the platform${NC}"
fi

# Verificar la disponibilidad de memoria
echo -e "${YELLOW}Checking memory availability${NC}"
MEM_GB=$(( $(sysctl hw.memsize | cut -d ' ' -f 2) / 1073741824 ))
if [ $MEM_GB -lt 18 ]; then
    echo -e "${RED}System RAM is ${MEM_GB}GB. This is insufficient to deploy a working cluster.${NC}"
    exit 1
fi
echo -e "${PURPLE}Memory resource is OK...${NC}"

# Determinar interfaz para bridge
interface=""
bridge_arg="--bridged"
echo -e "${YELLOW}Setting bride mode in multipass settings...${NC}"
for iface in $(multipass networks --format json | jq -r '.list[] | .name'); do
    if netstat -rn -f inet | grep "^default.*${iface}" > /dev/null; then
        interface=$iface
        echo -e "${GREEN}The platform will use the following network interface: $iface${NC}"
        break
    fi
done
echo -e "${PURPLE}interface: $interface${NC}"

if [ "$(multipass get local.bridged-network)" = "<empty>" ]; then
    echo -e "${YELLOW}Configuring bridge network...${NC}"

    if [ -z "${interface}" ]; then
        echo -e "${RED}No suitable interface detected to use as bridge"
        echo "Falling back to NAT installation"
        echo -e "You will not be able to use your browser to connect to NodePort services.${NC}"
        BUILD_MODE="NAT"
        exit 1
    else
        echo -e "${GREEN}Configuring bridge to interface '$(multipass networks | grep ${interface})'${NC}"
        multipass set local.bridged-network=${interface}
    fi
fi
echo -e "${PURPLE}Multipass bride mode is OK...${NC}"

# Si los nodos están en funcionamiento, reiniciarlos
echo -e "${YELLOW}Checking if virtual machines already exists...${NC}"
if multipass list --format json | jq -r '.list[].name' | grep -E '(rancher-extras|rancher-control-plane|rancher-node1)' > /dev/null; then
    echo -n -e $RED
    read -p "VMs are running. Stop, delete and rebuild them (y/n)? " ans
    echo -n -e $NC
    [ "$ans" != 'y' ] && exit 1
fi

echo -e "${GREEN}Deleting existing rancher virtual machines${NC}"
for node in rancher-extras rancher-control-plane rancher-node1
do
  echo -e "${PURPLE}Deleting virtual machine $node${NC}"
   multipass delete $node
   multipass purge
done
echo -e "${GREEN}Building from scratch deleted virtual machines${NC}"
if [ "$VOLUME_SHARING" == "true" ]; then
   VOLUME_MODE_WORKERS=" --mount ${LOCAL_VOLUMES_PATH}rancher-extras:/opt/rancher-extras"
   if ! multipass launch $bridge_arg$VOLUME_MODE_WORKERS --disk 40G --memory $EXTRAS_MEMORY --cpus 4 --name rancher-extras jammy; then
      sleep 1
   fi
   VOLUME_MODE_WORKERS=" --mount ${LOCAL_VOLUMES_PATH}rancher-control-plane:/opt/rancher-control-plane"
   if ! multipass launch $bridge_arg$VOLUME_MODE_WORKERS --disk 80G --memory $RANCHERS_MEMORY --cpus 8 --name rancher-control-plane jammy; then
      sleep 1
   fi
   VOLUME_MODE_WORKERS=" --mount ${LOCAL_VOLUMES_PATH}rancher-node1:/opt/rancher-node1"
   if ! multipass launch $bridge_arg$VOLUME_MODE_WORKERS --disk 80G --memory $RANCHERS_MEMORY --cpus 8 --name rancher-node1 jammy; then
      sleep 1
   fi
else
   if ! multipass launch $bridge_arg --disk 40G --memory $EXTRAS_MEMORY --cpus 4 --name rancher-extras jammy; then
      sleep 1
   fi
   if ! multipass launch $bridge_arg --disk 80G --memory $RANCHERS_MEMORY --cpus 8 --name rancher-control-plane jammy; then
      sleep 1
   fi
   if ! multipass launch $bridge_arg --disk 80G --memory $RANCHERS_MEMORY --cpus 8 --name rancher-node1 jammy; then
      sleep 1
   fi
fi
echo -e "${PURPLE}Rancher machines booted!${NC}"

# Create hostfile entries
echo -e "${YELLOW}Setting hostnames${NC}"
hostentries=/tmp/hostentries
network=$(netstat -rn -f inet | grep "^default.*${interface}" | awk '{print $2}' | awk 'BEGIN { FS="." } { printf "%s.%s.%s", $1, $2, $3 }')
[ -f $hostentries ] && rm -f $hostentries
echo -e "${GREEN}network: $network${NC}"
for node in rancher-extras rancher-control-plane rancher-node1
do
  ip=$(multipass info $node --format json | jq -r --arg nw $network 'first( .info[] )| .ipv4  | .[0] ')
  echo "$ip $node" >> $hostentries
done
echo -e "${PURPLE}hostname to configure $hostentries${NC}"
cat $hostentries


echo -e "${YELLOW}configuring each ip address and execute scripts ${NC}"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/scripts
for node in rancher-extras rancher-control-plane rancher-node1
do
   multipass transfer $hostentries $node:/tmp/
   multipass transfer $SCRIPT_DIR/*.sh $node:/tmp/
   for script in 01-setup-hosts.sh 02-setup-kernel.sh
   do
     multipass exec $node -- /tmp/$script
   done
   if [ "$node" = "rancher-extras" ]; then
      multipass exec $node -- sudo /tmp/05-install-extras.sh
   else
     RANCHER_DNS_NAME=$(multipass exec rancher-extras -- sudo hostname -I | awk '{print $1}')
     echo -e "${YELLOW}RANCHER_DNS_NAME: $RANCHER_DNS_NAME${NC}"
     multipass exec $node -- sudo /tmp/03-setup-cri.sh $RANCHER_DNS_NAME
     multipass restart $node
   fi
done


for node in rancher-control-plane rancher-node1
do
  multipass transfer $SCRIPT_DIR/04-run-cri.sh $node:/tmp/
  echo -e "${YELLOW}File 04-run-cri.sh transfered${NC}"
  multipass exec $node -- /tmp/04-run-cri.sh
  KEY=$(multipass exec $node -- docker logs rancher 2>&1 | grep "Bootstrap Password:")
  echo -e "${PURPLE}$node has docker $KEY${NC}"
done
echo -e "${PURPLE}all rancher VM's configured!!!${NC}"

echo -e "${GREEN}Rancher cluster setup is complete!${NC}"
#multipass exec rancher-control-plane -- kubectl get nodes
echo -e "${BLUE}Happy rancher hacking!!!"
