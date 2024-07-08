## Configure kubectl command to connect k8s-cluster

```console
multipass shell k8s-control-plane
```
In the control plane execute the following command:
```console
sudo cat /etc/kubernetes/admin.conf
```
Edit in the host machine kubernetes config file located at:
```console
$HOME/.kube/config
```
This file is a yaml containing the configuration for your local installation of kubectl

NOTE: If you config file is empty, feel free to copy al file of the k8s-control-plane in your local config fila.

Paste the values in the right place:
```yaml
clusters:
- cluster:
    certificate-authority-data: XXXXXXX
    server: https://your-control-plane-ip-address:6443
  name: kubernetes

contexts:
- context:
    cluster: kubernetes
    namespace: default
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes

users:
  - name: kubernetes-admin
    user:
      client-certificate-data: XXXXXXXXX
      client-key-data: XXXXXXXX
```

Test the configuration:
```console
git:(main) ✗ kubectl get nodes

NAME                STATUS   ROLES           AGE   VERSION
k8s-control-plane   Ready    control-plane   11h   v1.30.2
k8s-worker-node1    Ready    <none>          11h   v1.30.2
k8s-worker-node2    Ready    <none>          11h   v1.30.2
```
