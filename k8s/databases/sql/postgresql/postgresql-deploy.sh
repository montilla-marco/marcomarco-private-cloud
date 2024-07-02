#!/usr/bin/env bash
echo "First Step: Create Name Space for postgresql-16"
kubectl create namespace postgresql-16

kubectl config set-context --current --namespace=postgresql-16

#kubectl apply -f pv-4gi.yaml --namespace postgresql-16

echo "Second Step: Install Custom Persistent Volume Claim reducing the default to half"
kubectl apply -f pvc.yaml --namespace postgresql-16

echo "Third Step: Install Helm Chart Overriding persistence.existingClaim value"
helm upgrade --install postgresql --version 15.5.11 --values values.yaml  bitnami/postgresql

kubectl port-forward --namespace postgresql-16 svc/postgresql 5432:5432 &


