#!/usr/bin/env bash

BLUE="\033[1;34m"
NC="\033[0m"

# see: https://github.com/scriptcamp/kubernetes-jenkins

multipass exec k8s-worker-node1 -- sudo mkdir /mnt/k8s-worker-node1/jenkins
multipass exec k8s-worker-node1 -- sudo chmod 777 /mnt/k8s-worker-node1/jenkins

#Create a Namespace with name jenkins-ns
kubectl apply -f jenkins-ns.yaml

#Create a service account with Kubernetes admin permissions.
kubectl apply -f jenkins-sa.yaml

#Create local persistent volume for persistent Jenkins data on Pod restarts.
kubectl apply -f jenkins-pv.yaml
kubectl apply -f jenkins-pvc.yaml

#Create a deployment YAML and deploy it.
kubectl apply -f jenkins-deploy.yaml

#Create a service YAML and deploy it.
kubectl apply -f jenkins-svc.yaml

# Esperar a que todos los pods del plano de control estén en ejecución
echo -e "${BLUE}Waiting for jenkins pod to be running${NC}"
for s in $(seq 120 -10 10); do
    echo "Waiting $s seconds..."
    sleep 10
done

kubectl get all -n jenkins-ns

./install-plugins.sh

