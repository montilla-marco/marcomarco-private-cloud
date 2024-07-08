#!/usr/bin/env bash

#TODO: End this script and build another one for kubectl local cofig
BLUE="\033[1;34m"
PURPLE="\[\033[1;35m\]"
NC="\033[0m"

# Esperar a que todos los objetos de jenkins estén en ejecución
echo -e "${BLUE}Waiting for all jenkins objects will be created${NC}"
#for s in $(seq 60 -10 10); do
#    echo -e "${PURPLE}Waiting $s seconds...${NC}"
#    sleep 10
#done

#POD_NAME=$(kubectl get po -n jenkins-ns | awk '{print $1}' | grep -v "NAME")
#NODE_NAME=$(kubectl describe po $POD_NAME -n jenkins-ns | grep "Node:" | awk '{print $2}' | cut -d '/' -f 1)
#kubectl -n jenkins-ns exec --stdin --tty $POD_NAME -- chown -R jenkins:jenkins /var/lib/jenkins/

#kubectl logs deployment.apps/jenkins --namespace=jenkins-ns
#CLUSTER_INFO_INIT="certificate-authority-data:"
#CLUSTER_INFO_END="contexts:"
#
#CLUSTER_CONFIG=$(multipass exec k8s-control-plane -- sudo cat /etc/kubernetes/admin.conf)
##CLUSTER_NAME=$(awk "/$CLUSTER_INFO_INIT/{flag=1} flag; /$fin/{flag=0}" "$CLUSTER_CONFIG")
##CLUSTER_NAME=$(echo "$CLUSTER_CONFIG" | sed -n "s/.*$CLUSTER_INFO_INIT\([^$CLUSTER_INFO_END]*\).*/\1/p")
#CLUSTER_NAME=$(echo "$CLUSTER_CONFIG" | awk -v RS="$CLUSTER_INFO_INIT" -v FS="$CLUSTER_INFO_END" '{print $1}')
#echo "cluster: $CLUSTER_NAME"
#CERT_AUTH_DATA=$( (echo "$CLUSTER_NAME" | awk '{$1=$1;print}')) #$(echo "$CLUSTER_NAME" | awk '{match($0, /LS0t ([a-z]+)/, arr); print arr[1]}')
#echo "certificate-authority-data: $CERT_AUTH_DATA"

#temp=${$CLUSTER_CONFIG##*"- cluster:"}
#printf "%s\n" "${temp%%or*}"

#kubectl logs deployment.apps/jenkins --namespace=jenkins-ns
#CLUSTER_INFO_INIT="certificate-authority-data:"
#CLUSTER_INFO_END="contexts:"
#
## Obtener la configuración del clúster
#CLUSTER_CONFIG=$(multipass exec k8s-control-plane -- sudo cat /etc/kubernetes/admin.conf)
#
## Extraer el bloque de configuración relevante
#CLUSTER_NAME=$(echo "$CLUSTER_CONFIG" | awk -v start="$CLUSTER_INFO_INIT" -v end="$CLUSTER_INFO_END" '
#{
#    # Verificar si la línea contiene el inicio del bloque
#    if ($0 ~ start) {
#        flag = 1
#    }
#    # Si estamos dentro del bloque, imprimir la línea
#    if (flag) {
#        print $0
#    }
#    # Verificar si la línea contiene el final del bloque
#    if ($0 ~ end) {
#        flag = 0
#    }
#}')
#
## Limpiar el contenido extraído
#CERT_AUTH_DATA=$(echo "$CLUSTER_NAME" | awk '{$1=$1;print}')
#
## Mostrar los datos extraídos
#echo "cluster: $CLUSTER_NAME"
#echo "certificate-authority-data: $CERT_AUTH_DATA"