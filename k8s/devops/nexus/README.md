```
helm repo add sonatype https://sonatype.github.io/helm3-charts
helm repo update
```
1. Get the application URL by running these commands:
   export POD_NAME=$(kubectl get pods --namespace nexus-oss -l "app.kubernetes.io/name=nexus-repository-manager,app.kubernetes.io/instance=nexus-oss" -o jsonpath="{.items[0].metadata.name}")
   kubectl --namespace nexus-oss port-forward $POD_NAME 8081:80
   Your application is available at http://127.0.0.1
