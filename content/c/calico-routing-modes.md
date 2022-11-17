---
title: Calico Routing Modes
weight: 9989
description: A deep dive into how routing in Calico works.
date: 2020-01-19
images:
- https://octetz.s3.us-east-2.amazonaws.com/title-card-calico-routing-modes.png
aliases:
---

# Calico Routing Modes

How does Calico route container traffic? Many say "It uses
[BGP](https://en.wikipedia.org/wiki/Border_Gateway_Protocol) to route
unencapsulated traffic providing near-native network performance." They aren’t
completely wrong. It is **possible** to run Calico in this mode, but it is not
the default. It’s also a common misconception that BGP is how Calico routes
traffic; it is part, but Calico may also leverage
[IP-in-IP](https://en.wikipedia.org/wiki/IP_in_IP) or
[VXLAN](https://en.wikipedia.org/wiki/Virtual_Extensible_LAN) to perform
routing. In this post, I’ll attempt to explain the routing options of Calico and
how BGP compliments each.

{{< yblink MpbIZ1SmEkU >}}

## Example Architecture

For this demonstration, I have setup the following architecture in AWS. The
terraform is [here](https://github.com/octetz/calico-routing/blob/master/servers.tf).  The Calico deployment is
[here](https://raw.githubusercontent.com/octetz/calico-routing/master/calico.yaml).

{{< img src="https://octetz.s3.us-east-2.amazonaws.com/calico-aws-architecture.png" class="center" width="600">}}

For simplicity, there is only 1 master node. Worker nodes are spread across
availability zones in 2 different subnets. There will be 2 worker nodes in
subnet 1 and 1 worker node in subnet 2. Calico is the container networking
plugin across all nodes. Throughout this post, I'll refer to these nodes as
follows.

* `master`: Kube-Master-Node, subnet 1
* `worker-1`: Kube-Worker-Node 1, subnet 1
* `worker-2`: Kube-Worker-Node 2, subnet 1
* `worker-3`: Kube-Worker-Node 3, subnet 2

These are consistent with the node names in my Kubernetes cluster.

```
NAME       STATUS   ROLES    AGE     VERSION
master     Ready    master   6m55s   v1.17.0
worker-1   Ready    <none>   113s    v1.17.0
worker-2   Ready    <none>   77s     v1.17.0
worker-3   Ready    <none>   51s     v1.17.0
```

Pods are deployed with manifests for
[pod-1](https://raw.githubusercontent.com/octetz/calico-routing/master/pod-1.yaml),
[pod-2](https://raw.githubusercontent.com/octetz/calico-routing/master/pod-2.yaml),
and
[pod-3](https://raw.githubusercontent.com/octetz/calico-routing/master/pod-3.yaml).

```
NAME    READY   STATUS    RESTARTS   AGE     NODE
pod-1   1/1     Running   0          4m52s   worker-1
pod-2   1/1     Running   0          3m36    worker-2
pod-3   1/1     Running   0          3m23s   worker-3
```

## Route Sharing

By default, Calico uses
[BGP](https://en.wikipedia.org/wiki/Border_Gateway_Protocol) to distribute
routes amongst hosts. Calico-node pods run on every host. Each calico-node peers
together.

{{< img src="https://octetz.s3.us-east-2.amazonaws.com/routes.png"
class="center" >}}

The calico-node container hosts 2 processes.

1. **BIRD**: Shares routes via BGP.

2. **Felix**: Programs host route tables. 

BIRD can be configured for advanced BGP architectures, such as centralized route
sharing via [route
reflectors](http://octetz.com/docs/2018/2018-12-10-route-reflectors-in-calico/)
and peering with BGP-capable routers. Using
[calicoctl](https://docs.projectcalico.org/v3.11/getting-started/calicoctl/install#about-installing-calicoctl),
you can view nodes sharing routes. 

``` 
$ sudo calicoctl node status 

Calico process is running.

IPv4 BGP status
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 10.30.0.206  | node-to-node mesh | up    | 18:42:27 | Established |
| 10.30.0.56   | node-to-node mesh | up    | 18:42:27 | Established |
| 10.30.1.66   | node-to-node mesh | up    | 18:42:27 | Established |
+--------------+-------------------+-------+----------+-------------+

IPv6 BGP status
No IPv6 peers found.
``` 

Each host IP represents a node this host is peering with. This was run on
`master` and the IPs map as:

* `10.30.0.206`: worker-1
* `10.30.0.56`: worker-2
* `10.30.1.66`: worker-3

Once routes are shared, Felix programs a host's route table as follows. 

```
# run on master
$ route -n

Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.30.0.1       0.0.0.0         UG    100    0        0 ens5
10.30.0.0       0.0.0.0         255.255.255.0   U     0      0        0 ens5
10.30.0.1       0.0.0.0         255.255.255.255 UH    100    0        0 ens5
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
192.168.97.192  10.30.1.66      255.255.255.192 UG    0      0        0 tunl0
192.168.133.192 10.30.0.56      255.255.255.192 UG    0      0        0 tunl0
192.168.219.64  0.0.0.0         255.255.255.192 U     0      0        0 *
192.168.219.65  0.0.0.0         255.255.255.255 UH    0      0        0 cali50e69859f2f
192.168.219.66  0.0.0.0         255.255.255.255 UH    0      0        0 calif52892c3dce
192.168.226.64  10.30.0.206     255.255.255.192 UG    0      0        0 tunl0
```

These routes are programmed for IP-in-IP traffic. Each host's pod CIDR
(Destination + Genmask) goes through a `tunl0` interface. Pods, with endpoints,
have a  `cali*` interface, which is used for network policy enforcement.

## Routing 

Calico supports 3 routing modes. 

* **IP-in-IP**: default; encapsulated

* **Direct**: unencapsulated 

* **VXLAN**: encapsulated; no BGP 

IP-in-IP and VXLAN encapsulate packets. Encapsulated packets “feel” native to
the network they run atop.  For Kubernetes, this enables running a 'virtual' pod
network independent of the host network.

### IP-in-IP 

IP-in-IP is a simple form of encapsulation achieved by putting an IP packet
inside another. A transmitted packet contains an outer header with **host**
source and destination IPs and an inner header with **pod** source and
destination IPs.

{{< img
src="https://upload.wikimedia.org/wikipedia/commons/2/2d/IPTunnelDiagram_01-12-07.jpg"
class="center" width="600" >}}

In IP-in-IP mode, `worker-1`'s route table is as follows. 

```
# run on worker-1
sudo route
```

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/calico-route-table-ipip.png"
class="center" >}}

Below is a packet sent from pod-1 to pod-2.

```
# sent from inside pod-1
curl 192.168.133.194
```

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/calico-ipip-wireshark-data.png"
class="center" >}}

IP-in-IP also features a selective mode. It is used when only routing between
subnets requires encapsulation. I’ll explore this in the next section. 

I believe IP-in-IP is Calico’s default as it often *just works*. For example,
networks that reject packets without a host's IP as the destination or packets
where routers between subnets rely on the destination IP for a host.

### Direct 

Direct is a made up word I’m using for non-encapsulated routing. Direct sends
packets as if they came directly from the pod. Since there is no encapsulation
and de-capsulation overhead, direct is highly performant.

To route directly, the [Calico
IPPool](https://docs.projectcalico.org/v3.11/reference/resources/ippool#ip-pool-definition)
must not have IP-in-IP enabled. 

To modify the pool, download the default `ippool`. 

``` 
calicoctl get ippool default-ipv4-ippool -o yaml > ippool.yaml 
``` 

Disable IP-in-IP by setting it to `Never`. 

``` 
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  # remove creationTimestamp, resourceVersion,
  # and uid if present
  name: default-ipv4-ippool
spec:
  blockSize: 26
  cidr: 192.168.0.0/16
  ipipMode: Never
  natOutgoing: true
  nodeSelector: all()
  vxlanMode: Never
``` 

Apply the change.

``` 
calicoctl apply -f ippool.yaml 
``` 

On `worker-1`, the route table is updated.

```
route -n
``` 

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/calico-route-table-direct.png"
class="center" >}}

2 important changes are:

1. The `tunl0` interface is removed and all routes point to `ens5`.
2. `worker-3`'s route points to the network gateway (`10.30.0.1`) rather than
   the host.
   1. This is because worker-3 is on a different subnet.

With direct routing, requests from `pod-1` to `pod-2` fail.

```
# sent from pod-1
$ curl -v4 192.168.133.194 --max-time 10

*   Trying 192.168.133.194:80...
* TCP_NODELAY set
* Connection timed out after 10001 milliseconds
* Closing connection 0
curl: (28) Connection timed out after 10001 milliseconds
```

Packets are blocked because src/dst checks are enabled. To fix this, disable these
checks on every host in AWS. 

{{< img src="https://octetz.s3.us-east-2.amazonaws.com/aws-src-dst-check.png"
class="center" width="600" >}}

Traffic is now routable between `pod-1` and `pod-2`. The wireshark output is as
follows.

``` 
curl -v4 192.168.133.194
``` 

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/calico-direct-wireshark-data.png"
class="center" >}}

However, communication between `pod-1` and `pod-3` now fails. 

```
# sent from pod-1 
$ curl 192.168.97.193 --max-time 10

curl: (28) Connection timed out after 10000 milliseconds
``` 

Do you remember the updated route table? On `worker-1`, traffic sent to
`worker-3` routes to the network gateway rather than to `worker-3`. This is
because `worker-3` lives on a different subnet. When the packet reaches the
network gateway, it does not have a routable IP address, instead it only sees
the `pod-3` IP.

Calico supports a `CrossSubnet` setting for IP-in-IP routing. This setting tells
Calico to only use IP-in-IP when crossing a subnet boundary. This gives you
high-performance direct routing inside a subnet and still enables you to route
across subnets, at the cost of some encapsulation.

{{< img src="https://octetz.s3.us-east-2.amazonaws.com/direct-and-ipip-flow.png"
class="center" width="600" >}}

To enable this, update the IPPool as follows.

``` 
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: default-ipv4-ippool
spec:
  blockSize: 26
  cidr: 192.168.0.0/16
  ipipMode: CrossSubnet
  natOutgoing: true
  nodeSelector: all()
  vxlanMode: Never
``` 

``` 
calicoctl apply -f ippool.yaml 
``` 

Now routing between all pods works! Examining `worker-1`'s route table: 

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/calico-route-table-ipip-crosssubnet.png"
class="center" >}}

The `tunl0` interface is reintroduced for routing to `worker-3`.

### VXLAN 

VXLAN routing is supported in Calico 3.7+. Historically, to route traffic using
VXLAN and use Calico policy enforcement, you’d need to deploy Flannel and
Calico. This was referred to as [Canal](https://github.com/projectcalico/canal).
Whether you use VXLAN or IP-in-IP is determined by your network architecture.
VXLAN is feature rich way to create a virtualized layer 2 network. It fosters
larger header sizes and likely requires more processing power to facilitate.
VXLAN is great for networks that do not support IP-in-IP, such as Azure, or
don’t support BGP, which is disabled in VXLAN mode. 

Setting up Calico to use VXLAN fundamentally changes how routing occurs. Thus
rather than altering the IPPool, I'll be redeploying on a new cluster.

To enable VXLAN, as of Calico 3.11, you need to make the following 3 changes to
the [Calico manifest](https://docs.projectcalico.org/v3.11/manifests/calico.yaml).

1. Set the `backend` to `vxlan`.

``` 
kind: ConfigMap 
apiVersion: v1 
metadata: 
  name: calico-config 
  namespace: kube-system 
data: 
  # Typha is disabled. 
  typha_service_name: “none” 
  # value changed from bird to vxlan 
  calico_backend: “vxlan” 
``` 

2. Set the `CALICO_IPV4_IPIP` pool to `CALICO_IPV4_VXLAN`.

```
            # Enable VXLAN
            - name: CALICO_IPV4POOL_VXLAN
              value: "Always"

```

4. Disable BGP-related liveness and readiness checks. 

``` 
livenessProbe:
  exec:
    command:
    - /bin/calico-node
    - -felix-live
# disable bird liveness test
#    - -bird-live
  periodSeconds: 10
  initialDelaySeconds: 10
  failureThreshold: 6
readinessProbe:
  exec:
    command:
    - /bin/calico-node
    - -felix-ready
# disable bird readiness test
#    - -bird-ready
  periodSeconds: 10
``` 

Then apply the modified configuration. 

``` 
kubectl apply -f calico.yaml 
``` 

With VXLAN enabled, you can now see changes to the route tables. 

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/vxlan-tunnel-interfaces.png"
class="center" >}}

Inspecting the packets shows the VXLAN-style encapsulation and how it differs
from IP-in-IP. 

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/vxlan-tunnel-wireshark.png"
class="center" >}}

## Summary 

Now that we've explored routing in Calico using IP-in-IP, Direct, and VXLAN, I
hope you’re feeling more knowledgable about Calico’s routing options.
Additionally, I hope these options demonstrate that Calico is a fantastic
container networking plugin, extremely capable in most network environments.


