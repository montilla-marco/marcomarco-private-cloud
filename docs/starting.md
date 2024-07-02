# Getting started

## Building control-plane and worker nodes 

Ansible inventory can be stored in 3 formats: YAML, JSON, or INI-like. There is
an example inventory located
[here](https://github.com/kubernetes-sigs/kubespray/blob/master/inventory/sample/inventory.ini).

You can use an
[inventory generator](https://github.com/kubernetes-sigs/kubespray/blob/master/contrib/inventory_builder/inventory.py)
to create or modify an Ansible inventory. Currently, it is limited in
functionality and is only used for configuring a basic Kubespray cluster inventory, but it does
support creating inventory file for large clusters as well. It now supports
separated ETCD and Kubernetes control plane roles from node role if the size exceeds a
certain threshold. Run `python3 contrib/inventory_builder/inventory.py help` for more information.

Example inventory generator usage:

```ShellSession
cp -r inventory/sample inventory/mycluster
declare -a IPS=(10.10.1.3 10.10.1.4 10.10.1.5)
CONFIG_FILE=inventory/mycluster/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}