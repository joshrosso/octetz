---
title: Kubernetes Static Pods
date: 2019-10-12
aliases:
  - /posts/k8s-static-pods
  - /posts/k8s-static-pods.html
weight: 9993
---

# Static Pods

A kubelet can be pointed to a directory of
[pod](https://kubernetes.io/docs/concepts/workloads/pods/pod/) manifests. While
running, the kubelet creates and manages the lifecycle for these pods. This
allows you to create pods without connectivity to a Kubernetes control plane.
These pods are referred to as static pods. If you are wondering when you would
ever need this, you are not alone! In this post you will learn how static pods
work, when to use them, and best practice considerations.

## How Static Pods Work

The kubelet features an optional flag, `--pod-manifest-path` (or `staticPodPath`
if using [kubelet
configuration](https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/#create-the-config-file)).
This points to a directory. When started, the kubelet attempts to create a pod
for each manifest in this directory. The kubelet does not require connection to
an API server to start these pods. This means the kubelet manages the pod’s
lifecycle.

When connected to an API server, the kubelet reports the pods. These reported
pods are called [mirror
pods](https://kubernetes.io/docs/reference/glossary/?all=true#term-mirror-pod).
With mirror pods, you can execute many common commands. For example, `kubectl
get logs` to retrieve logs, `kubectl exec` to run a command in a pod’s
container, and `kubectl describe` to get pod details.  Unfortunately, mirror
pods create the illusion that you can impact the pod's lifecycle. For example,
when deleting the mirror pod from the API server you may expect the pod will be
terminated. This is not the case. While the mirror pod could be deleted, the
kubelet manages the lifecycle independent of the control plane. The only way to
affect the pod's lifecycle is to modify the manifest on the kubelet’s host.

## When to Use Static Pods

As far as I remember (I could be wrong) static pods were introduced for running
pods across all or a subset of chosen nodes. This was useful for system services
such as log forwarders ([fluentd](https://www.fluentd.org/)) and networking
components
([kube-proxy](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/)).
[Daemonsets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
were eventually introduced to solve this problem. Most deploy instructions for
these aforementioned services recommend deploying a daemonset. There are
mentions throughout GitHub of historical intentions to remove static pods.

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/k8s-static-pods/tweet1.png"
width="800" >}}

When should you use them? I’d argue, almost never. If considering static pods,
first determine whether a daemonset is adequate. Daemonsets are entirely managed
via the Kubernetes control plane. Adding, deleting, and modifying a daemonset is
like any other Kubernetes objects Since they are created through the API server,
they are managed centrally and go through the API server’s RBAC and admission
control. The key feature to static pods that _may_ justify the use is that they
**do not require connectivity to the API server.** As mentioned earlier, the
host’s kubelet manages the lifecycle. Two use cases I am aware of are as
follows.

1. Hosting the Kubernetes control plane.
2. IoT and edge deployments.

Creating the Kubernetes control plane via static pods is
[kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)’s
approach. In order to run the `kube-apiserver`, `kube-controller-manager`, and
`kube-scheduler` as pods, you need to create them before the control plane
exists. A classic chicken and the egg dilemma. Static pods solve this.

IoT and Edge deployments are newer cases that I haven’t seen in the wild yet,
but may benefit from static pods. 

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/k8s-static-pods/tweet2.png"
width="800" >}}

_redacted for brevity, full comment
[here](https://github.com/kubernetes/kubeadm/issues/1541#issuecomment-488112516)._

In this model, kubelets run on edge or low-resource nodes that need to bootstrap
pods but cannot rely on having an API server around. Using configuration
management, manifests can be pushed to the hosts and, assuming the kubelet is
running, pods are created. You could introduce an API server at a central
location and the kubelets will then create mirror pods. As described earlier,
these mirror pods will allow viewing logs, running commands, and getting pod
information from various kubelets.

## Best Practices

Static pods should only be enabled on hosts that require the functionality. In
most kubeadm deployments, static pods are required on control-plane nodes.
However, they are enabled on worker nodes as well. Unless you require static
pods to run on workers, disabling this on the kubelet is advisable. It removes a
potential start-up vector where, if a manifest was persisted to the static pod
directory, a pod would come online. Since static pods aren’t created via the API
server, no RBAC or admission control is considered. This leads into your next
consideration, PSPs.

Pod Security Policies (PSPs) are recommended for most clusters. You can read
more about them in my [Setting Up Pod Security
Policies](https://octetz.com/posts/setting-up-psps) post. When enabled, pods
created via the API Server are checked against policies to determine whether the
pod’s spec is compliant with security requirements. This does not apply to
static pods as they are managed via the kubelet. However, it does apply to the
mirror pods created by the kubelet! So the static pod is created by the kubelet,
but the mirror pod is blocked when a valid PSP is not found. This enables rogue
pods to run in the Kubernetes cluster with no visibility via the API server. In
this scenario, a kubelet reports logs similar to the following.


```
Aug 12 01:45:41 192-168-122-170 kubelet[870]: E0812 01:45:41.314772     870 kubelet.go:1639] Failed creating a mirror pod for "nginx-static-192-168-122-170_default(301a236dba67940cb11c948b95e6aff3)": pods "nginx-static-192-168-122-170" is forbidden: unable to validate against any pod security policy: [spec.securityContext.hostNetwork: Invalid value: true: Host network is not allowed to be used spec.containers[0].hostPort: Invalid value: 80: Host port 80 is not allowed to be used. Allowed ports: []]
```


To resolve this, the group `system:nodes` should have access to a privileged
PSP, allowing mirror pods of any form to be created via the kubelet.


```
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: psp-permissive-nodes
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: psp-permissive
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:nodes

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: psp-permissive
rules:
- apiGroups:
  - extensions
  resourceNames:
  - permissive
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

This assumes a PSP exists named `permissive`.
