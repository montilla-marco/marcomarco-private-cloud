# Requirements

- Canonical Multipass [Ubuntu VMs on demand](https://multipass.run/).
- 
- **Minimum required version of Kubernetes is v1.29**
- The target servers must have **access to the Internet** in order to pull docker images.
- The target servers are configured to allow **IPv4 forwarding**.

Hardware:
These limits are requirements for your workload and can differ depending of your purposes.
For a sizing guide go to the [Building Large Clusters](https://kubernetes.io/docs/setup/cluster-large/#size-of-master-and-master-components) guide.

- Master
  - Memory: 2 GB
- Nodes
  - Memory: 4 GB
- Disk
  - Master 5GB
  - Worker 30GB