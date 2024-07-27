#!/usr/bin/env bash

YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # Sin color

echo -e "${YELLOW}First Step: deleting zot${NC}"
helm uninstall zot

echo -e "${YELLOW}Second Step: Install Helm Chart Overriding without values${NC}"
kubectl delete namespace zot-ns

echo -e "${BLUE}Zot deleted...${NC}"

