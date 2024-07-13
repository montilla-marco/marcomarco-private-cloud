#!/usr/bin/env bash

YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # Sin color

echo -e "${YELLOW}Setting helm repository for Istio${NC}"
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
echo -e "${BLUE}helm repository for Istio updated${NC}"

kubectl create namespace istio-system
echo -e "${BLUE}namespace istio-system created${NC}"

echo -e "${YELLOW}Installing Istio base components${NC}"
helm install istio-base istio/base -n istio-system --set defaultRevision=default --wait
echo -e "${BLUE}Istio base components installed${NC}"

echo -e "${YELLOW}Installing Istio networking components${NC}"
helm install istio-cni istio/cni -n istio-system --set profile=ambient --wait
echo -e "${BLUE}Istio networking components installed${NC}"

echo -e "${YELLOW}Installing Istiod components${NC}"
helm install istiod istio/istiod -n istio-system --set profile=ambient --wait
echo -e "${BLUE}Istiod components installed${NC}"

echo -e "${YELLOW}Installing ztunnel components${NC}"
helm install ztunnel istio/ztunnel -n istio-system --wait
echo -e "${BLUE}ztunnel components installed${NC}"

echo -e "${YELLOW}Installing istio-ingress components${NC}"
helm install istio-ingress istio/gateway -n istio-ingress --set values.global.proxy.image=istio/proxyv2 --create-namespace --wait
echo -e "${BLUE}istio-ingress components installed${NC}"

# Esperar a que reinicie jenkins
echo -e "${YELLOW}Waiting for load istio${NC}"
for s in $(seq 60 -10 10); do
    echo -e "${BLUE}Waiting $s seconds...${NC}"
    sleep 10
done

echo -e "${YELLOW}ls -n istio-system${NC}"
helm ls -n istio-system

echo -e "${YELLOW}status istiod -n istio-system${NC}"
helm status istiod -n istio-system

echo -e "${YELLOW}get deployments -n istio-system${NC}"
kubectl get deployments -n istio-system --output wide

echo -e "${YELLOW}get pods -n istio-system${NC}"
kubectl get pods -n istio-system

kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
{ kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd/experimental?ref=v1.1.0" | kubectl apply -f -; }

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/addons/kiali.yaml
