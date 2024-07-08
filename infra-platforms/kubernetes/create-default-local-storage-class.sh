#!/usr/bin/env bash

kubectl apply -f manifests/local-storage-class.yaml

kubectl patch storageclass local-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl get storageclass