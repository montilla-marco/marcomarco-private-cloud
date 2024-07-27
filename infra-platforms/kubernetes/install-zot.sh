#!/bin/bash

YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # Sin color

echo -e "${YELLOW}Executing zot installation $0...${NC}"
cd oci-registry/zot
./zot-deploy.sh
echo -e "${YELLOW}Zot installed!!!${NC}"