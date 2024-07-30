#!/usr/bin/env bash

BLUE="\033[1;34m"
NC="\033[0m"

echo -e "${BLUE}Creating a Namespace with name dind-ns${NC}"
kubectl apply -f dind-ns.yaml

echo -e "${BLUE}Creating pod${NC}"
#kubectl apply -f dind-pod.yaml

echo -e "${BLUE}Creating a deployment for pod${NC}"
kubectl apply -f dind-deploy.yaml

echo -e "${BLUE}Waiting for dind pod to be running${NC}"
for s in $(seq 40 -10 10); do
    echo "Waiting $s seconds..."
    sleep 10
done

kubectl get all -n dind-ns


