#!/bin/bash

# Check if the namespace argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

# Assign the namespace from the argument
NAMESPACE="$1"

# List all resource types except namespaces and delete them
for resource in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "namespaces"); do
  kubectl delete --ignore-not-found=true --namespace="${NAMESPACE}" "$resource" --all
done

# if have a persistent volume
PV=$(kubectl get pv | grep "jenkins-ns" | awk '{print $1}')
if [[ -n "$PV" ]]; then
    kubectl delete pv $PV -n ${NAMESPACE}
fi

#TODO delete users role and rolebinding
#name_to=$(echo "NAMESPACE" | cut -d '-' -f 1)
#user_to=$(kubectl get clusterrol | grep name_to | awk '{print $1}')
#echo "clusterrole user_to is $user_to"
#kubectl get clusterrolebindings
#user_to=$(kubectl get clusterrolebindings | grep name_to | awk '{print $1}')
#echo "clusterrolebinding user_to is $user_to"

# Finally, delete the namespace itself
kubectl delete namespace "${NAMESPACE}"
