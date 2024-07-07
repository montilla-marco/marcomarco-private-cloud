#!/usr/bin/env bash

# see: https://github.com/scriptcamp/kubernetes-jenkins

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


