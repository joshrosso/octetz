---
title: Securing Communication to Controller Manager and Scheduler
weight: 10000
date: 2018-12-05
aliases:
  - /posts/secure-port-k8s-cm-sched
  - /posts/secure-port-k8s-cm-sched.html
---

# Securing Controller Manager and Scheduler Metrics

I've been looking into interacting with the secure (tls) ports for the
`kube-scheduler` and `kube-controller-manager` and wanted to share my findings.

**Video Walkthrough:**

{{< yblink dhPy3lWWhoU >}}

Based on the [1.12
changelog](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.12.md),
secure serving on `10257` to the `kube-controller-manager` is enabled:

> Secure serving on port 10257 to kube-controller-manager (configurable via
> --secure-port) is now enabled. Delegated authentication and authorization are
> to be configured using the same flags as for aggregated API servers. Without
> configuration, the secure port will only allow access to /healthz. (#64149,
> @sttts) Courtesy of SIG API Machinery, SIG Auth, SIG Cloud Provider, SIG
> Scheduling, and SIG Testing

Based on the [1.13
changelog](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.13.md)
secure serving on `10259` to the `kube-scheduler` is enabled:

> Added secure port 10259 to the kube-scheduler (enabled by default) and
> deprecate old insecure port 10251. Without further flags self-signed certs are
> created on startup in memory. (#69663, @sttts)

With the `kube-controller-manager` running, we can call the pod IP and verify
`/healthz` is available.

```
curl https://10.30.0.12:10257/healthz -k

ok
```

When calling the `/metrics` endpoint, you'll get less satisfying results.

```
curl https://10.30.0.12:10257/metrics -k

Internal Server Error: "/metrics": subjectaccessreviews.authorization.k8s.io is forbidden: User "system:kube-controller-manager" cannot create resource "subjectaccessreviews" in API group "authorization.k8s.io" at the cluster scope
```

You might wonder **why** this path/resource is different than `/healthz`. It
turns out `/healthz` is automatically set for authorization to always allow it.
By setting `--authorization-always-allow-paths=/healthz,/metrics` on the
`kube-controller-manager`, we can get `/metrics` to behave the same. Instead,
let's force authorization of the client to ensure not just anyone can scrape
these system components.

We want `kube-controller-manager` to delegate authorization decisions to
`kube-apiserver`. It does this by sending a
[SubjectAccessReview](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#checking-api-access).

`kube-controller-manager` must be bound to the existing `system:auth-delegator`
`ClusterRole`.

```
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: system:kube-controller-manager:auth-delegate
subjects:
- kind: User
  name: system:kube-controller-manager
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: system:auth-delegator
  apiGroup: rbac.authorization.k8s.io
```

After applying the `ClusterRoleBinding`, request the metrics endpoint. It will
now show we cannot access the `/metrics` url.

```
curl https://10.30.0.12:10257/metrics -k
```

```
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {

  },
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/metrics\"",
  "reason": "Forbidden",
  "details": {

  },
  "code": 403
}
```

For this example, let's give default:default (`<namespace>:<service-account>`)
access to the `/metrics` `nonResourceURLs`. Normally you'd be providing this
access to a Prometheus service account.

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secure-metrics-scrape
rules:
- apiGroups:
  - ""
  resources:
  - nodes/metrics
  verbs:
  - get
- nonResourceURLs:
  - /metrics
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: metrics-endpoint
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: secure-metrics-scrape
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
```

Retrieve the default:default token into an environment variable.

```
TOKEN=$(kubectl describe secret $(kubectl get secrets -n default | grep ^default | cut -f1 -d ' ') | grep -E '^token' | cut -f2 -d':' | tr -d " ")
```

Request the secure metrics endpoint again.

```
curl https://10.30.0.12:10257/metrics --header "Authorization: Bearer $TOKEN" -k

...
volumes_work_duration{quantile="0.5"} NaN
volumes_work_duration{quantile="0.9"} NaN
volumes_work_duration{quantile="0.99"} NaN
volumes_work_duration_sum 0
volumes_work_duration_count 0
```

Hopefully this provides a better idea of how secure port communication and
authorization works. You can take these learnings and setup secure interactions
from clients like Prometheus.
