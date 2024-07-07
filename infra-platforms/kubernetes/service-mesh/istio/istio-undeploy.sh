#List all the Istio charts installed in istio-system namespace:

helm ls -n istio-system

#(Optional) Delete any Istio gateway chart installations:

helm delete istio-ingress -n istio-ingress
kubectl delete namespace istio-ingress

#Delete Istio discovery chart:
helm delete istiod -n istio-system

#Delete Istio base chart:

#By design, deleting a chart via Helm doesn’t delete the installed Custom Resource Definitions (CRDs) installed via the chart.
helm delete istio-base -n istio-system

#Delete the istio-system namespace:

kubectl delete namespace istio-system