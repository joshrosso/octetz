---
title: 2019 US Kubecon
weight: 9991
date: 2019-11-22
aliases:
  - /posts/k8s-kubecon-sd-review
  - /posts/k8s-kubecon-sd-review.html
---

# Kubecon San Diego Takeaways

I had such a killer week at Kubecon. I tried to lay low and truly be an
attendee. I was lucky enough to see many insightful talks. This post contains my
thoughts, observations, and learnings from the conference. Most of what follows
is intuition and opinion -- so take it **all** with a grain of salt.

## Cilium Gaining

I'm a Calico fan. I've seen it scale in massive Kubernetes deployments over
multiple years. In fact, if you're considering a production-ready CNI for
Kubernetes today, I still believe you should be looking at Calico. Cilium has
been making noise in the community for some time now, especially with their use
of eBPF to facilitate routing. A talk by Martynas Pumputis identified the
standard path of a request with Kubernetes default service mode, iptables.

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/k8s-kubecon-sd-review/packetflow.png"
>}}

With eBPF, we take a more direct path, no longer needing to traverse tons of
complex, unreadable chain rules. Cilium makes many operations to determine what
to do with routing map lookups. Essentially moving to O(1) with common
operations.

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/k8s-kubecon-sd-review/packetflowebpf.png"
>}}

iptables works and we can generally assume Linux hosts will have it. It was a
great choice for Kubernetes to use initially. Cilium's argument is that removal
of iptables usage promotes scalability.

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/k8s-kubecon-sd-review/perf.png"
>}}

Now you'll notice, IPVS, which is a mode already supported by kube-proxy, also
increases scalability.  So this could be a good option if using eBPF in your
environment is not possible. For example, some financial institutions (and other
legacy-prone users :)) may run older versions of RHEL where eBPF is not enabled.
However, our reliance on iptables as a whole, has been challenging. As your
cluster grows, iptables rules get really complex and hard to debug.
Additionally, as I understand it, to change iptables rules, you need to rewrite
the entire chains. iptables also gets used for more than just Kubernetes
services, CNIs may implement their network policy rules in iptables, which just
adds to the complexity of the rule chains.  Additionally, eBPF brings a lot of
opportunity to introspect and better understand the flow of traffic. I have been
waiting to see how Cilium will try to capitalize on this. This Kubecon, they
announced Hubble, which attempts to provide observability to your pod/container
traffic.

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/k8s-kubecon-sd-review/hubble.png"
>}}

This is **super** interesting. Introducing a solid introspection toolset that
anyone running Cilium can use would be a high value add for those evaluating
open-source CNI-plugin options. The UI looks pretty solid at first glance.

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/k8s-kubecon-sd-review/hubbleservicemap.png"
>}}

For me, it's still TBD how Isovalent, creators and maintainers of Cilium, will
make their money. If this introspection toolset remains open and free, it'd be a
big leg up for Cilium in my opinion.  Talking to strangers at Kubecon, people
are excited to see how this project progresses.  I am **stoked** to try out
Cilium in my homelab! While I probably wouldn't adopt it without an engineering
team that really knew their shit regarding eBPF, it is worth keeping on your
radar!  Lastly, be sure to [checkout Martynas's
talk](https://kccncna19.sched.com/event/Uaam/liberating-kubernetes-from-kube-proxy-and-iptables-martynas-pumputis-cilium)
once it's on YouTube!

## Gitops Success

Conceptually, I dig the idea of gitops. However, reality is most of my clients
are still wrapping their heads around how to best integrate Jenkins with
Kubernetes to prevent developers from deploying via their desktop. So I have
mostly stayed distant from projects like Flux and Argo in hopes soon enough
people would share their gitops stories. For me, this Kubecon was the first time
I'd heard stories of some of the awesome work companies are doing to enable
gitops. Many gitops systems, such as Argo run in the cluster and are able to
have better introspection of how a workload is rolled out. Intuit demonstrated
how they were able to do this to facilitate more controlled continuous delivery
coined progressive delivery.

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/k8s-kubecon-sd-review/pdelivery.png"
>}}

The benefit to these systems running in cluster is you can introspect workload
specific details to determine whether you can continue to rollout or need to
rollback. In the same talk, Intuit showed how you can facilitate a canary
rollout with specific steps.

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/k8s-kubecon-sd-review/canaryintuit.png"
>}}

The template referenced here has many advanced capabilities. Namely the ability
to run a Prometheus query to determine the health of a rollout.

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/k8s-kubecon-sd-review/analytemp.png"
>}}

I also learned [Argo and Flux and coming together to better facilitate
gitops](mplate referenced here has many advanced capabilities. Namely the
ability to run a prometheus query to determine the health of a rollout.).
Lastly, I heard a few time during the conference, how platform teams view gitops
as an opportunity to lessen the friction of on-boarding for their application
teams. More on that in the next section!

## Adoption Depends on Abstraction

We have always been told Kubernetes is **not a platform**; it's container
orchestration. Many buy fully-baked "platforms" such as OpenShift that provide a
more turn-key solution running container workloads. The groups I work with
prefer to build their own platforms, which Kubernetes is one part of. Many
believe that ideally your developers should not know their workloads run on
Kubernetes.  Generally I agree with this sentiment, but it often does not line
up with reality.  Many shops setup advanced RBAC and policy, tell developers to
download `kubectl`, and go to town, interacting directly with Kubernetes. This
approach is not egregious...What many of the tweets stating "you shouldn't know
you're on k8s" are overlooking is the complex, dragon-filled, rabbit hole that
is determining how to best abstract k8s in your platform. However...these
tweeters aren't wrong either. Talk after talk showed that successful adoption of
Kubernetes was often driven by how low friction it was for developers to get
their workloads up and running. I know this is an obvious statement. But time
and time again we lose sight of this concept! 

Pintrest demonstrated their introduction of CRDs. These enabled developers to
provide basic details about their apps that a controller could take and
translate into the 300+ lines of YAML it takes to get it up and running.

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/k8s-kubecon-sd-review/pin.png"
>}}

Uber had a great talk about how they took their existing control plane, that
developers were used to interacting with, and adapted it to work with Kubernetes
and Mesos. This way, where workloads landed was completely transparent to
developers. It would also enable them to move off of Mesos over time with no
migration overhead.

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/k8s-kubecon-sd-review/peloton.png"
>}}

Lastly, many Kubernetes operators were viewing Gitops (discussed above) as an
opportunity to lessen the burden on moving to Kubernetes. Namely everything
being driven by repo commits rather than direct interaction with `kubectl`.

## End Users are Key

With the massive flood of vendors in the Kubernetes space, it was great that so
many of the talks revolved around experiences teams have had around Kubernetes.
Project and product-focused talks can be great too but I derive most of my value
from hearing the war stories of the end users. I know it is not always easy to
get your company to let you talk openly about what you're working on, for those
who did, thanks so much for sharing with us!

To everyone involved, thanks for an awesome Kubecon. Can't wait to watch
recordings of all the talks I missed.
