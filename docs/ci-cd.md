# Install CI / CD

## Building

    $ cd /infra-platforms/kubernetes/k8s
    $ ./install-cicd.sh

The resulting output is going to print in the CLI

Verify the installation creation:
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

TODO: Make a complete script with option to use Jenkins or ArgoCD


## Uninstall Chart

```console
# TODO uninstall script
```

This removes all 

