#!/usr/bin/env bash

YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # Sin color

echo -e "${YELLOW}First Step: Create Name Space for Zot Registry${NC}"
kubectl apply -f zot-ns.yaml

echo -e "${YELLOW}Second Step: Install Helm Chart Overriding without values${NC}"
helm repo add project-zot http://zotregistry.dev/helm-charts
helm repo update project-zot

helm upgrade --install -f values.yaml zot project-zot/zot --namespace zot-ns

echo -e "${YELLOW}Third Step: linking to a kubeconfig file${NC}"
helm install zot project-zot/zot --kubeconfig $HOME/.kube/config

helm list

echo -e "${YELLOW}Fourth Step: getting server url${NC}"
NODE_PORT=$(kubectl get --namespace zot-ns -o jsonpath="{.spec.ports[0].nodePort}" services zot)
NODE_IP=$(kubectl get nodes --namespace zot-ns -o jsonpath="{.items[0].status.addresses[0].address}")

echo "http://$NODE_IP:$NODE_PORT"
# curl http://$NODE_IP:$NODE_PORT/v2/_catalog
