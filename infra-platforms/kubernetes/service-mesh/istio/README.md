A service mesh is a distributed application infrastructure that is responsible for handling
network traffic on behalf of the application in a transparent, out-of-process manner

The data plane is responsible for establishing, securing, and
controlling the traffic through the mesh. The data plane behavior is configured by the
control plane. The control plane is the brains of the mesh and exposes an API for operators
to manipulate network behaviors. Together, the data plane and the control
plane provide important capabilities necessary in any cloud-native architecture

 Service resilience
 Observability signals
 Traffic control capabilities
 Security
 Policy enforcement


The service mesh takes on the responsibility of making service communication resilient
to failures by implementing capabilities like retries, timeouts, and circuit breakers.
It’s also capable of handling evolving infrastructure topologies by handling things
like service discovery, adaptive and zone-aware load balancing, and health checking.
Since all the traffic flows through the mesh, operators can control and direct traffic
explicitly. For example, if we want to deploy a new version of our application, we may
want to expose it to only a small fraction, say 1%, of live traffic. With the service mesh
in place, we have the power to do that. Of course, the converse of control in the service
mesh is understanding its current behavior. Since traffic flows through the mesh,
we’re able to capture detailed signals about the behavior of the network by tracking
metrics like request spikes, latency, throughput, failures, and so on. We can use this
telemetry to paint a picture of what’s happening in our system. Finally, since the service
mesh controls both ends of the network communication between applications, it
can enforce strong security like transport-layer encryption with mutual authentication:
specifically, using the mutual Transport Layer Security (mTLS) protocol.
Data plane
Proxy
App
Proxy
App

An important requirement for any services-based architecture is security. Istio has
security enabled by default. Since Istio controls each end of the application’s networking
path, it can transparently encrypt the traffic by default. In fact, to take it a step further,
Istio can manage key and certificate issuance, installation, and rotation so that

services get mutual TLS out of the box. If you’ve ever experienced the pain of installing
and configuring certificates for mutual TLS, you’ll appreciate both the simplicity
of operation and how powerful this capability is. Istio can assign a workload identity
and embed that into the certificates. Istio can also use the identities of different workloads
to further implement powerful access-control policies.
Finally, but no less important than the previous capabilities, with Istio you can
implement quotas, rate limiting, and organizational policies. Using Istio’s policy
enforcement, you can create very fine-grained rules about what services are allowed to
interact with each other, and which are not. This becomes especially important when
deploying services across clouds (public and on premises).
Istio is a powerful implementation of a service mesh. Its capabilities allow you
to simplify running and operating a cloud-native services architecture, potentially
across a hybrid environment. Throughout the rest of this book, we’ll show you how to
take advantage of Istio’s functionality to operate your microservices in a cloud-native
world.

Using a service mesh does have a few drawbacks you must be aware of.
First, using a service mesh puts another piece of middleware, specifically a proxy,
in the request path. This proxy can deliver a lot of value; but for those unfamiliar with
the proxy, it can end up being a black box and make it harder to debug an application’s
behavior. The Envoy proxy is specifically built to be very debuggable by exposing
a lot about what’s happening on the network—more so than if it wasn’t there—but
for someone unfamiliar with operating Envoy, it could look very complex and inhibit
existing debugging practices.
Another drawback of using a service mesh is in terms of tenancy. A mesh is as valuable
as the services running in the mesh. That is, the more services in the mesh, the
more valuable the mesh becomes for operating those services. However, without
proper policy, automation, and forethought going into the tenancy and isolation
models of the physical mesh deployment, you could end up in a situation where misconfiguring
the mesh impacts many services.
Finally, a service mesh becomes a fundamentally important piece of your services
and application architecture since it’s on the request path. A service mesh can expose
a lot of opportunities to improve security, observability, and routing control posture.
The downside is that a mesh introduces another layer and another opportunity for
complexity. It can be difficult to understand how to configure, operate, and, most
importantly, integrate it within your existing organizational processes and governance
and between existing teams.

Finally, a service mesh becomes a fundamentally important piece of your services
and application architecture since it’s on the request path. A service mesh can expose
a lot of opportunities to improve security, observability, and routing control posture.
The downside is that a mesh introduces another layer and another opportunity for
complexity. It can be difficult to understand how to configure, operate, and, most
importantly, integrate it within your existing organizational processes and governance
and between existing teams.

istioctl x precheck

istioctl verify-install



The control
plane provides a way for users of the service mesh to control, observe, manage, and
configure the mesh. For Istio, the control plane provides the following functions:
 APIs for operators to specify desired routing/resilience behavior
 APIs for the data plane to consume their configuration
 A service discovery abstraction for the data plane
 APIs for specifying usage policies
 Certificate issuance and rotation
 Workload identity assignment
 Unified telemetry collection
 Service-proxy sidecar injection
 Specification of network boundaries and how to access them
The bulk of these responsibilities is implemented in a single control-plane component
called istiod


istioctl kube-inject

The istioctl kube-inject command takes a Kubernetes resource file and enriches
it with the sidecar deployment of the Istio service proxy and a few additional components

In Kubernetes, the smallest unit of deployment is called a Pod. A Pod can be one or
more containers deployed atomically together. When we run kube-inject, we add
another container named istio-proxy to the Pod template in the Deployment object,
although we haven’t actually deployed anything yet. We could deploy the YAML file
created by the kube-inject command directly; however, we are going to take advantage
of Istio’s ability to automatically inject the sidecar proxy.
To enable automatic injection, we label the istioinaction namespace with
istio-injection=enable


istioctl dashboard kiali
istioctl dashboard grafana
istioctl dashboard jaeger

The Envoy proxy is specifically an application-level proxy that we can insert into the
request path of our applications to provide things like service discovery, load balancing,
and health checking
As a proxy, Envoy is designed to shield developers from networking concerns by
running out-of-process from applications. This means any application written in any
programming language or with any framework can take advantage of these features

Envoy’s core features
Envoy has many features useful for inter-service communication. To help understand
these features and capabilities, you should be familiar with the following Envoy concepts
at a high level:
 Listeners—Expose a port to the outside world to which applications can connect.
For example, a listener on port 80 accepts traffic and applies any configured
behavior to that traffic.
 Routes—Routing rules for how to handle traffic that comes in on listeners. For
example, if a request comes in and matches /catalog, direct that traffic to the
catalog cluster.
 Clusters—Specific upstream services to which Envoy can route traffic. For example,
catalog-v1 and catalog-v2 can be separate clusters, and routes can specify
rules about how to direct traffic to either v1 or v2 of the catalog service.

SERVICE DISCOVERY
Instead of using runtime-specific libraries for client-side service discovery, Envoy can
do this automatically for an application. By configuring Envoy to look for service endpoints
from a simple discovery API, applications can be agnostic to how service endpoints
are found. The discovery API is a simple REST API that can be used to wrap
other common service-discovery APIs (like HashiCorp Consul, Apache ZooKeeper,
Netflix Eureka, and so on). Istio’s control plane implements this API out of the box.
Envoy is specifically built to rely on eventually consistent updates to the service-discovery
catalog. This means in a distributed system we cannot expect to know the exact status
of all services with which we can communicate and whether they’re available. The best
we can do is use the knowledge at hand, employ active and passive health checking, and
expect that those results may not be the most up to date (nor could they be).
Istio abstracts away a lot of this detail by providing a higher-level set of resources
that drives the configuration of Envoy’s service-discovery mechanisms

LOAD BALANCING
Envoy implements a few advanced load-balancing algorithms that applications can
take advantage of. One of the more interesting capabilities of Envoy’s load-balancing
algorithms is the locality-aware load balancing. In this situation, Envoy is smart enough
to keep traffic from crossing any locality boundaries unless it meets certain criteria
and will provide a better balance of traffic. For example, Envoy makes sure that service-
to-service traffic is routed to instances in the same locality unless doing so would
create a failure situation. Envoy provides out-of-the-box load-balancing algorithms for
the following strategies:
 Random
 Round robin
 Weighted, least request
 Consistent hashing (sticky)

TRAFFIC SHIFTING AND SHADOWING CAPABILITIES
Envoy supports percentage-based (that is, weighted) traffic splitting/shifting. This
enables agile teams to use continuous delivery techniques that mitigate risk such as
canary releases. Although they mitigate risk to a smaller user pool, canary releases still
deal with live user traffic.
Envoy can also make copies of the traffic and shadow that traffic in a fire and forget
mode to an Envoy cluster. You can think of this shadowing capability as something like
traffic splitting, but the requests that the upstream cluster sees are a copy of the live
traffic; thus we can route shadowed traffic to a new version of a service without really
acting on live production traffic

NETWORK RESILIENCE
Envoy can be used to offload certain classes of resilience problems, but note that it’s
the application’s responsibility to fine-tune and configure these parameters. Envoy
can automatically do request timeouts as well as request-level retries (with per-retry
timeouts). This type of retry behavior is very useful when a request experiences intermittent
network instability. On the other hand, retry amplification can lead to cascading
failures; Envoy allows you to limit retry behavior. Also note that application-level
retries may still be needed and cannot be completely offloaded to Envoy. Additionally,
when Envoy calls upstream clusters, it can be configured with bulkheading characteristics
like limiting the number of connections or outstanding requests in flight and to
fast-fail any that exceed those thresholds (with some jitter on those thresholds).
Finally, Envoy can perform outlier detection, which behaves like a circuit breaker, and
eject endpoints from the load-balancing pool when they misbehave.

HTTP/2 AND GRPC
HTTP/2 is a significant improvement to the HTTP protocol that allows multiplexing
requests over a single connection, server-push interactions, streaming interactions,
and request backpressure. Envoy was built from the beginning to be an HTTP/1.1
and HTTP/2 proxy with proxying capabilities for each protocol both downstream and
upstream. This means, for example, that Envoy can accept HTTP/1.1 connections
and proxy to HTTP/2—or vice versa—or proxy incoming HTTP/2 to upstream
HTTP/2 clusters. gRPC is an RPC protocol using Google Protocol Buffers (Protobuf)
that lives on top of HTTP/2 and is also natively supported by Envoy. These are powerful
features (and difficult to get correct in an implementation) and differentiate
Envoy from other service proxies.


OBSERVABILITY WITH DISTRIBUTED TRACING
Envoy can report trace spans to OpenTracing (http://opentracing.io) engines to visualize
traffic flow, hops, and latency in a call graph. This means you don’t have to install
special OpenTracing libraries. On the other hand, the application is responsible for
propagating the necessary Zipkin headers, which can be done with thin wrapper
libraries.
Envoy generates a x-request-id header to correlate calls across services and can
also generate the initial x-b3* headers when tracing is triggered. The headers that the
application is responsible for propagating are as follows:
 x-b3-traceid
 x-b3-spanid
 x-b3-parentspanid
 x-b3-sampled
 x-b3-flags

AUTOMATIC TLS TERMINATION AND ORIGINATION
Envoy can terminate Transport Level Security (TLS) traffic destined for a specific service
both at the edge of a cluster and deep within a mesh of service proxies. A more
interesting capability is that Envoy can be used to originate TLS traffic to an upstream
cluster on behalf of an application. For enterprise developers and operators, this means
we don’t have to muck with language-specific settings and keystores or truststores. By
having Envoy in our request path, we can automatically get TLS and even mutual TLS.
RATE LIMITING
An important aspect of resiliency is the ability to restrict or limit access to resources
that are protected. Resources like databases or caches or shared services may be protected
for various reasons:
 Expensive to call (per-invocation cost)
 Slow or unpredictable latency
 Fairness algorithms needed to protect against starvation
Especially as services are configured for retries, we don’t want to magnify the effect of
certain failures in the system. To help throttle requests in these scenarios, we can use a
global rate-limiting service. Envoy can integrate with a rate-limiting service at both the
network (per connection) and HTTP (per request) levels.

Istio gateways

Traffic ingress concepts
The networking community has a term for connecting networks via well-established
entry points: ingress points. Ingress refers to traffic that originates outside the network
and is intended for an endpoint within the network. The traffic is first routed to an
ingress point that acts as a gatekeeper for traffic coming into the network. The ingress
point enforces rules and policies about what traffic is allowed into the local network. If
the ingress point allows the traffic, it proxies the traffic to the correct endpoint in the
local network. If the traffic is not allowed, the ingress point rejects the traffic.

Virtual IPs: Simplifying service access
How traffic is routed to a network’s
ingress points—at least
Let’s say we have a service that we wish to expose at api.marcomarco.blog/v1/catalogs/1232/products
for external systems to get a list of products in our catalog. When our client tries to
query that endpoint, the client’s networking stack first tries to resolve the api.marcomarco.blog 
domain name to an IP address. This is done with DNS servers. The networking
stack queries the DNS servers for the IP addresses for a particular hostname. So the
first step in getting traffic into our network is to map our service’s IP to a hostname in
DNS. For a public address, we could use a service like Amazon Route 53 or Google
Cloud DNS and map a domain name to an IP address. In our own datacenters, we’d
use internal DNS servers to do the same thing.

Specifying Gateway resources

´´´yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
name: marcomarco-gateway
spec:
selector:
istio: ingressgateway
servers:
- port:
  number: 80
  name: http
  protocol: HTTP
  hosts:
- "webapp.marcomarco.blog
´´´

istioctl analyze
