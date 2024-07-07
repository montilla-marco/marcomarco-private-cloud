# Requirements

## Software Generic

- Git: [Installing Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- SDK man: [Installation](https://sdkman.io/install)
- Java 21: ```sdk install java java 21.0.3-tem```
- Gradle: see documentetion [ Gradle release 8.8 Installation with sdkman](https://sdkman.io/sdks#:~:text=sdk%20install%20grace-,Gradle,-(8.8))
- IntelliJ CE or Whatever be your favorite IDE.
- Canonical Multipass: [Ubuntu VMs on demand](https://multipass.run/).
- Linux jq Command: [Installation guide](https://github.com/jqlang/jq/wiki/Installation)
- Kubectl: [Command-line tool](https://kubernetes.io/docs/tasks/tools/)
- Helm: [Helm CLI](https://helm.sh/docs/intro/install/)

### On Mac 
- Brew 
- We are going to install the latest K8s with registry.k8s.io/pause:3.9 (please see how to synchronize it in the install script)

### On Windows
- Chocolate

**TODO: Build the scripts in powershell**

## Hardware:
These limits are requirements for your workload and can differ depending of your purposes.
For a sizing guide go to the [Building Large Clusters](https://kubernetes.io/docs/setup/cluster-large/#size-of-master-and-master-components) guide.

These are a preliminary resources at this moment (start building) after that when you have a clear idea of your needs you can adjust it.
- Master
  - Memory: 2 GB
- Nodes
  - Memory: 8 GB
- Disk
  - Master 50GB
  - Worker 100GB
- Cpu
  - 8

### NOTES:
- The target servers must have **access to the Internet** in order to pull OCI images.
- The target servers are configured to allow **IPv4 forwarding**.