#!/usr/bin/env bash
# see: https://www.jenkins.io/doc/book/installing/kubernetes/

helm repo add jenkinsci https://charts.jenkins.io
helm repo update

kubectl create namespace jenkins

kubectl apply -f jenkinns-pv.yaml

kubectl apply -f jenkins.sa.yaml

chart=jenkinsci/jenkins
helm upgrade --install jenkins -n jenkins -f jenkins-values.yaml $chart

jsonpath="{.data.jenkins-admin-password}"
secret=$(kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)
echo $(echo $secret | base64 --decode)

jsonpath="{.spec.ports[0].nodePort}"
NODE_PORT=$(kubectl get -n jenkins -o jsonpath=$jsonpath services jenkins)
jsonpath="{.items[0].status.addresses[0].address}"
NODE_IP=$(kubectl get nodes -n jenkins -o jsonpath=$jsonpath)
echo http://$NODE_IP:$NODE_PORT/login

kubectl get pods -n jenkins

kubectl -n jenkins port-forward jenkins-0 8082:8080

