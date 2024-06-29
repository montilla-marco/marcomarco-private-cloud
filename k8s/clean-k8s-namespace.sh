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

# Finally, delete the namespace itself
kubectl delete namespace "${NAMESPACE}"