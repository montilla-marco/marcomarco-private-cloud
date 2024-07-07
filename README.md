# K8S Development Platform Boiler Plate

The following project has the aim of speed up the development of distributed applications using a cluster oriented
platform such as kubernetes, making a local installation of it give the opportunity of explore features and 
export the application in any public cloud.

For first version we will be installing the kubernetes system with control plane node and two worker nodes we are going 
to need a machine with a Mac OS (It's my default laptop)

Litle by litle we will add some update to running this platform using Rancher K3S or Docker Desktop both for windows 
anc Mac, please feel free to add some additions (Linux)  to it.

## Please refer to the minimum system requirements for each OS and kubernetes way to run
- What I need to run on it? [Requirements](./docs/requirements.md)

## Install Platform
- Install [Getting Started](./docs/starting.md)

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

## Install CI/CD
- Install [Getting Started](./docs/ci-cd.md)