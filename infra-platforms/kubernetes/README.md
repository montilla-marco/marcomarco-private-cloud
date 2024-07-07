# Kubernetes
Kubernetes is a platform that manages and automates the deployment and scaling
of applications that run in containers, hosted either in the cloud or on-premises.
Leveraging the benefits of such a virtualized infrastructure to deploy microservices
comes with hidden security complexities. There are three vital security concerns
when it comes to an orchestration system like Kubernetes: malicious threat actors,
supply chain risks, and insider threats.
Supply chain risks creep in primarily at the time of development and packaging of
applications and are hard to mitigate. For mitigation, you must go back and correct
the issue in the life cycle of application development. Malicious threat components
can exploit the vulnerabilities and insecure configurations in components of
Kubernetes, such as API server, worker nodes and control planes. Insider threats
are generally user entities with special access to Kubernetes infrastructure and the
intention to abuse the privilege they have.
In this chapter, you will gain insights into the challenges of securing a Kubernetes
cluster. It will include the strategies that are commonly used by developers and
system administrators to mitigate the potential risks in container applications
deployed on Kubernetes.

kubectl api-resources --sort-by name -o wide


certificates = cert, certs
certificiaterequests = cr, crs
certificatesigningrequests = csr
componentstatuses = cs
configmaps = cm
cronjobs = cj
customresourcedefinitions = crd, crds
daemonsets = ds
deployments = deploy
endpoints = ep
events = ev
horizontalpodautoscalers = hpa
ingresses = ing
limitranges = limits
namespaces = ns
networkpolicies = netpol
nodes = no
persistentvolumes = pv
persistentvolumeclaims = pvc
pods = po
podsecuritypolicies = psp
priorityclasses = pc
replicationcontrollers = rc
replicasets = rs
resourcequotas = quota
scheduledscalers = ss
services = svc
serviceaccounts = sa
statefulsets = sts
storageclasses = sc