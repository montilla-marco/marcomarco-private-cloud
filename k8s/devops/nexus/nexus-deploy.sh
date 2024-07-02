#!/usr/bin/env bash
echo "First Step: Create Name Space for nexus-oss"
kubectl create namespace nexus-oss

kubectl config set-context --current --namespace=nexus-oss

echo "Second Step: Install Custom Persistent Volume Claim reducing the default to half"
kubectl apply -f pvc.yaml --namespace nexus-oss

echo "Third Step: Install Helm Chart Overriding persistence.existingClaim value"
helm upgrade --install nexus-oss sonatype/nexus-repository-manager -f values.yaml

export POD_NAME=$(kubectl get pods --namespace nexus-oss -l "app.kubernetes.io/name=nexus-repository-manager,app.kubernetes.io/instance=nexus-oss" -o jsonpath="{.items[0].metadata.name}")

kubectl --namespace nexus-oss port-forward $POD_NAME 8081:80


