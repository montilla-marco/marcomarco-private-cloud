#!/bin/bash

YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # Sin color

echo -e "${YELLOW}Executing $0...${NC}"
cd service-mesh/istio
./istio-deploy.sh
