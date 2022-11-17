---
title: Contour - Ingress with Envoy
weight: 9996
date: 2019-04-12
aliases:
  - /posts/contour-adv-ing-and-delegation
  - /posts/contour-adv-ing-and-delegation.html
---

# Contour: Advanced Ingress with Envoy

Contour is an ingress controller that configures Envoy based on Ingress and
IngressRoute objects in a Kubernetes cluster. This post covers how Contour
supports advanced ingress functionality with its
[IngressRoute](https://github.com/heptio/contour/blob/master/docs/ingressroute.md)
Custom Resource Definition (CRD). We'll explore some common ingress needs such
as weighted load balancing and cover how multi-team ingress can be facilitated.

{{< yblink O7HfkgzD7Z0 >}}

## How Contour Works

A simplified view of Contour is a pod with an Envoy container and controller.
The controller (named contour) is responsible for reading Ingress and
IngressRoute objects and creating a directed acyclic graph (DAG). Contour can
then communicate with the Envoy container to program routes to pods.

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/pod-contour.png" width="200" >}}

Contour is typically deployed in a cluster as a Deployment or Daemonset. We just
need to determine how to route to the Envoy instances. To send traffic to them,
we can expose the Envoy container using hostNetwork, hostPort, NodePort, or
other options. Checkout the Kubernetes documentation to determine the best path
for your architecture.

We can find the latest Contour manifest at
[https://j.hept.io/contour-deployment-rbac](https://j.hept.io/contour-deployment-rbac).

## IngressRoute Objects

Kubernetes offers an Ingress API. This API supports defining layer 7 rules that
tell a controller (such as NGINX or HAProxy) how to route traffic to pods. An
example manifest that exposes a ping service for requests at `ping.octetz.com`
is as follows.

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ping
  namespace: ping
spec:
  rules:
  - host: ping.octetz.com
    http:
      paths:
      - path: /
        backend:
          serviceName: pingv1
          servicePort: 8000
```

This generic object is perfect for defining how to route traffic entering at
`ping.octetz.com` to the pod endpoints behind the service `pingv1`. This could
be easily transposed to an NGINX, HAProxy, or Contour API.

However, those who have done layer 7 routing rules know that the above object is
fairly limited. It does not support common behavior we may want to express in
our routes, such as the following.

* TLS passthrough
* TCP proxying
* Selecting a balancing algorithm
* Route weights
* Resource delegation

This is a challenge many ingress controllers must solve for. Many move these
more specific requirements into [annotations in the
metadata](https://github.com/kubernetes-sigs/aws-alb-ingress-controller/blob/master/docs/guide/ingress/annotation.md)
of the ingress objects. While this works, it can cause very messy definitions
that are hard to reason with and troubleshoot. Annotations aren't validated on
apply, so it is up to the controller to fail if the value is malformed. We'd
rather have the client (kubectl) be able to tell us about things such as
syntactical issues.

So let us look at a specific use case, canary deployments. What if we want to
weight and slowly bleed traffic over to a new pingv2 application? Considering
the following diagram.

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/canary.png" width="600" >}}

For use cases that are more advanced than what the Ingress API supports
natively, Contour introduces the
[IngressRoute](https://github.com/heptio/contour/blob/master/docs/ingressroute.md)
custom resource definition (CRD). Contour can read Ingress and/or IngressRoutes
set within a cluster. When more advanced use cases such as the canary deployment
described above are presented, the IngressRoute can be easily leveraged. An
example of this weighting is as follows.

```
apiVersion: contour.heptio.com/v1beta1
kind: IngressRoute
metadata:
  name: ping
  namespace: ping
spec:
  virtualhost:
    fqdn: ping.octetz.com
  routes:
    - match: /
      services:
        - name: pingv1
          port: 8000
          weight: 85
        - name: pingv2
          port: 8000
          weight: 15
```

See the
[IngressRoute](https://github.com/heptio/contour/blob/master/docs/ingressroute.md)
documentation for details on all the capabilities.

## Route Delegation

Clusters supporting multiple teams have unique ingress challenges. Like many
parts of Kubernetes, once a cluster is in use by more than one team, handling
the multi-tenant needs or isolation becomes challenging. In Kubernetes, we often
scope team's resources by namespace. Often clusters are setup to offer a
shared-ingress layer. Meaning a set of load balancers and controllers run inside
the cluster offering layer 7 routing to different team's workloads. Consider the
following running in a cluster.

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/ingress-multi-team.png"
width="600" >}}

Notice the `host` value highlighted in yellow in the `team-a` and `team-b`
namespaces. Both attempt to define routing rules for the host `a.team.com`. Each
set a different destination (dest), team-a-pod and team-b-pod respectively. This
raises interesting questions: 

* Will the load balancer act deterministically? 
* If so, which destination will win? 
* Why was `team-b` able to request `a.team.com`? 
* How can we reserve such such domains to only `team-a`?

There are a multitude of ways to solve this. One is to implement a
[ValidatingWebhook](https://github.com/stevesloka/validatingwebhook) admission
controller capable of ensuring teams only request their "owned" domains. Another
is to rely on delegation of the ingress controller itself. This is where Contour
shines. By implementing an administrative ingress namespace, we can create
delegation rules for the ingress rules requested by other teams or namespaces.
Consider the following, revised, model.


{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/delegation.png" width="800" >}}

In the above, you can see a new namespace, `ingress-system`. This namespace
contains delegation rules for the FQDN and routes a namespace is allowed to
write rules for. As you can see in the `lines` namespace, if an IngressRoute is
created referencing the FQDN `mountains.octetz.com`, the route is not created.

An example of this Mountains delegation rule is as follows.

```
apiVersion: contour.heptio.com/v1beta1
kind: IngressRoute
metadata:
  name: mountain-delegation
  namespace: ingress-system
spec:
  virtualhost:
    fqdn: mountains.octetz.com
  routes:
    - match: /
      delegate:
        name: mountains
        namespace: mountains
```

Subsequently, when the IngressRoute is created for `mountains` in the
`mountains` namespace, it will feature a simpler structure, as follows.

```
apiVersion: contour.heptio.com/v1beta1
kind: IngressRoute
metadata:
  name: mountains
  namespace: mountains
spec:
  routes:
    - match: /
      services:
        - name: mountains
          port: 8000
```

> This manifest is absent of the `spec.virtualhost.fqdn` field, as it's assumed
> from the delegation rule.

To run in this delegated mode, simply add
`--ingressroute-root-namespaces=ingress-system` to the Contour pod's arguments.

## TLS Certificate Delegation

TLS Certificates face a similar issue in a multi-team environment. Often teams
must add their own certificate and key as a secret in Kubernetes and then
reference that secret in the ingress object. Most ingress controllers understand
this and are able to serve the certificate on behalf of the application.
Additionally, some ingress controllers support the notion of a "default"
certificate. This is often a wildcard certificate that can be used across the
entire organization. The following diagram details these different means of
certificate resolution.

{{< img class="center" src="https://octetz.s3.us-east-2.amazonaws.com/cert.png"
width="600" >}}

This approach can be limiting, especially when operating under the following
constraints.

* You want to manage certificates separate from the team's namespace.
* You don't want the teams to be responsible for certificates (and especially do
  not want to expose a private key).
* You want to introduce an approval process where you can "delegate" the usage
  of certificates.
* You don't want everyone to use the wildcard certificate (or perhaps you have
  multiple different wildcard certs).

Similar to route delegation, we can introduce TLSCertificateDelegation objects
to solve these problems. Consider the following diagram.

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/tls-delegation.png" width="400"
>}}

In the same `ingress-system` namespace, we can add certificates (as Kubernetes
secrets). These can then be referenced by a `TLSCertificateDelegation` objects.
These objects hold a list of namespaces that can reference the certificate from
their `IngressRoute` objects. In the diagram above, when the lines namespace
attempts to reference the `octetz-tls` secret, the route is not created.
IngressRoutes must also prefix the secret name with the namespace it is stored
(not represented in the diagram above). An example delegation object is as
follows.

```
apiVersion: contour.heptio.com/v1beta1
kind: TLSCertificateDelegation
metadata:
  name: octetz-tls
  namespace: ingress-system
spec:
  delegations:
  - secretName: octetz-tls
    targetNamespaces:
    - mountains
    - trails
```

The IngressRoute referencing this secret (from the `mountains` namespace) would look as follows.

```
apiVersion: contour.heptio.com/v1beta1
kind: IngressRoute
metadata:
  name: mountains
  namespace: mountains
spec:
  virtualhost:
    fqdn: mountains.octetz.com
    tls:
      secretName: ingress-system/octetz-tls
  routes:
    - match: /
      services:
        - name: mountains
          port: 8000
```

## Summary

I hope you found this post and video on Contour and ingress helpful!
