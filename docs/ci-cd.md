# Install CI / CD

## Building

    $ cd infra-platforms/kubernetes/
    $ ./install-jenkins.sh

The resulting output is going to print in the CLI

### Verify the installation creation:
```console
kubectl get all -n jenkins-ns   

NAME                          READY   STATUS    RESTARTS   AGE
pod/jenkins-68c8b7f55-jt7fp   1/1     Running   0          3m23s

NAME                      TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
service/jenkins-service   NodePort                 <none>        8080:32000/TCP   3m23s

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/jenkins   1/1     1            1           3m23s

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/jenkins-68c8b7f55   1         1         1       3m23s
```

### TODO: Make a complete script with option to use Jenkins or ArgoCD

### You can get that from the pod logs either from the Kubernetes dashboard or CLI. 

#### You can get the pod details using the following CLI command.

```console
kubectl get pods --namespace=jenkins-ns
```
With the pod name, you can get the logs as shown below. Replace the pod name with your pod name.
```console
kubectl logs deployment.apps/jenkins --namespace=jenkins-ns
```
The password can be found at the end of the log.

#### Alternatively, you can run the exec command to get the password directly from the location as shown below.
```console
kubectl exec -it pod/<pod_name> cat /var/jenkins_home/secrets/initialAdminPassword -n jenkins-ns
```

### Changing the owner of jobs to the jenkins user

kubectl describe pod/<pod_name> -n jenkins-ns

# Configuration

### Fisrt Time
Open your browser and visit the following address:
   
    http://<NODE_IP_ADDRESS>:32000

## Uninstall Chart

```console
# TODO uninstall script
```

This removes all 

