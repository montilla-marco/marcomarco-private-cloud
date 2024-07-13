#!/usr/bin/env bash

YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # Sin color

multipass exec k8s-worker-node1 -- sudo mkdir /mnt/k8s-worker-node1/postgresql
multipass exec k8s-worker-node1 -- sudo chmod 777 /mnt/k8s-worker-node1/postgresql

echo -e "${YELLOW}First Step: Create Name Space for postgresql16-ns${NC}"
kubectl apply -f postgresql-ns.yaml

#kubectl config set-context --current --namespace=postgresql16-ns
#kubectl apply -f pv-4gi.yaml --namespace postgresql16-ns

echo -e "${YELLOW}Second Step: Install Local Persistent Volume and Custom Persistent Volume Claim reducing the default to half${NC}"
kubectl apply -f postgresql-pv.yaml

kubectl apply -f postgresql-pvc.yaml

echo -e "${YELLOW}Third Step: Install Helm Chart Overriding persistence.existingClaim value${NC}"
helm upgrade --install postgresql --version 15.5.15 --values values.yaml  bitnami/postgresql --namespace postgresql16-ns

#kubectl port-forward --namespace postgresql16-ns svc/postgresql 5432:5432 &


