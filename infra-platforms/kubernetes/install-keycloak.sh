#!/bin/bash

YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # Sin color

echo -e "${YELLOW}Executing keycloak-deploy.sh...${NC}"
cd iam
./keycloak-deploy.sh


# Esperar a que reinicie jenkins
echo -e "${BLUE}Waiting for start keycloak${NC}"
for s in $(seq 90 -10 10); do
    echo -e "${YELLOW}Waiting $s seconds...${NC}"
    sleep 10
done

kubectl get all -n keycloak-ns
