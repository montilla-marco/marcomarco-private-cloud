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

## Configure K8S or K3S to use host kubectl command
- Configure [kubectl](./docs/kubectl-config.md))

## Configure base default storage class

A StorageClass provides a way for administrators to describe the classes of storage they offer. Different classes might map to quality-of-service levels, or to backup policies, or to arbitrary policies determined by the cluster administrators. Kubernetes itself is unopinionated about what classes represent.


    $ cd infra-platforms/kubernetes/
    $ ./create-default-local-storage-class.sh

## Install Istio Service Mesh (Optional you can install a ingress controller)
- Install [Istio](./docs/istio.md)

## Install PostgreSQL
- Install [PostgreSQL](./docs/postgresql.md)

## Install Keycloack server IAM
- Install [Keycloack](./docs/keycloack.md)

## Install Kubernetes Ingress Controller (If you installed Istio, skip this step)
**NOTE:** if you plan to run a service mesh, you may not need Ingress.
- Install [Ingress](./docs/ingress.md)

## Install CI/CD
- Install [Getting Started](./docs/ci-cd.md)


# NAMING OF RESOURCES
name-object Ej jenkins-ns

