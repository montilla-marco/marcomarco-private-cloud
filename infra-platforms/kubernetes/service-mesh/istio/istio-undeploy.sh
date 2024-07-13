#!/usr/bin/env bash

YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RED="\033[1;31m"
NC="\033[0m" # Sin color

echo -e "${YELLOW}List all the Istio charts installed in istio-system namespace:${NC}"
helm ls -n istio-system

echo -e "${YELLOW}Delete any Istio gateway chart installations${NC}"
helm delete istio-ingress -n istio-ingress
kubectl delete namespace istio-ingress

echo -e "${YELLOW}Delete the Istio CNI chart${NC}"
helm delete istio-cni -n istio-system

echo -e "${YELLOW}Delete the Istio ztunnel chart${NC}"
helm delete ztunnel -n istio-system

echo -e "${YELLOW}Delete the Istio discovery chart${NC}"
helm delete istiod -n istio-system

echo -e "${YELLOW}Delete the Istio base chart${NC}"
echo -e "${RED}By design, deleting a chart via Helm doesn’t delete the installed Custom Resource Definitions (CRDs) installed via the chart${NC}"
helm delete istio-base -n istio-system

echo -e "${YELLOW}Delete CRDs installed by Istio${NC}"
echo -e "${RED}This will delete all created Istio resources${NC}"
kubectl get crd -oname | grep --color=never 'istio.io' | xargs kubectl delete

echo -e "${YELLOW}Delete the istio-system namespace${NC}"
kubectl delete namespace istio-system

