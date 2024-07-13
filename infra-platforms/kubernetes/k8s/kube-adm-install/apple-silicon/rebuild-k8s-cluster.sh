#!/usr/bin/env bash

# Colores para la salida de terminal
RED="\033[1;31m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
NC="\033[0m"

cd /Users/marcomontilla/development/java/marcorp/baseline/infra-platforms/kubernetes/k8s/kube-adm-install/apple-silicon
./install-k8s-cluster.sh 1 -auto -bridge -volume-sharing=true

# Verificar el código de salida
if [ $? -gt 0 ]; then
  echo -e "${RED}install-k8s-cluster.sh fail with code $?.${NC}"
  exit 1
fi

echo -e "${GREEN}Making a backup of you current kubectl config file${NC}"
FILE_NAME=$HOME/.kube/config
if [ -e "nombre_archivo" ]; then
    CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M")
    echo -e "${GREEN}Current Time : $CURRENT_TIME${NC}"
    NEW_FILE_FILENAME="$FILE_NAME.$CURRENT_TIME"
    echo -e "${YELLOW}New FileName: " "$NEW_FILE_FILENAME${NC}"
    CP_FILE=$(cp $FILE_NAME $NEW_FILE_FILENAME)
    RM_FILE=$(rm $FILE_NAME)
fi

# Captura la configuración del clúster en una variable
CLUSTER_CONFIG=$(multipass exec k8s-control-plane -- sudo cat /etc/kubernetes/admin.conf)

# Verifica si la captura fue exitosa
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: can not get cluster config in control plane node.${NC}"
  exit 1
fi

# Usa yq para formatear y guardar la configuración en el archivo
echo "$CLUSTER_CONFIG" | yq eval -P -I=2 > $FILE_NAME

# Verifica si yq tuvo éxito
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: yq fail during configuration file tidy.${NC}"
  exit 1
fi

echo -e "${BLUE}La configuración del clúster se ha guardado en $FILE_NAME${NC}"


#touch $FILE_NAME
#CLUSTER_CONFIG=$(multipass exec k8s-control-plane -- sudo cat /etc/kubernetes/admin.conf | yq eval -P -I=2 > $FILE_NAME)

cd /Users/marcomontilla/development/java/marcorp/baseline/infra-platforms/kubernetes
kubectl get nodes -o wide

./create-default-local-storage-class.sh

./install-istio.sh

./install-postgresql.sh

./install-keycloack.sh

./install-jenkins-cicd.sh 1 #kubectl logs deployment.apps/jenkins --namespace=jenkins-ns

echo -e "${GREEN}Kubernetes cluster setup is complete!${NC}"
multipass exec k8s-control-plane -- kubectl get nodes -o wide
echo -e "${BLUE}Happy k8s hacking!!!"
