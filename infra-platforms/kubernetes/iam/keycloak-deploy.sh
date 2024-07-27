#!/usr/bin/env bash

YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # Sin color

#multipass exec k8s-worker-node1 -- sudo mkdir /mnt/k8s-worker-node1/postgresql
#multipass exec k8s-worker-node1 -- sudo chmod 777 /mnt/k8s-worker-node1/postgresql

echo -e "${YELLOW}First Step: Create Name Space for keycloak-ns${NC}"
kubectl apply -f keycloak-ns.yaml

echo -e "${YELLOW}Second Step: Install Helm Chart Overriding values${NC}"

CLUSTER_IP=$(kubectl describe svc postgresql -n postgresql-ns | grep "IP:" | awk '{print $2}')

helm upgrade --install keycloak --values values.yaml --set externalDatabase.host=$CLUSTER_IP bitnami/keycloak --namespace keycloak-ns
