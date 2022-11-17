---
title: Calico Route Refelctors
weight: 9998
date: 2018-12-10
aliases:
  - /posts/rr-setup
  - /posts/rr-setup.html
---

# Configuring Route Reflectors in Calico

Calico is a popular CNI plugin for Kubernetes. It leverages Border Gateway
Protocol (BGP) for communicating routes available on nodes. This method fosters
a highly scalable networking model between our workloads.

{{< yblink gxzLrgsKhBw >}}

## The Case for Route Reflection

Calico requires no additional routers or infrastructure to run. Like many CNI
plugins, you can apply it using `kubectl`.

```
kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
```

Once started, Calico runs a node-to-node mesh. This means every node peers to
every other node to broadcast routes. This is done from the `calico/node` pod
that runs on every node (via a daemonset). Let's assume a 5 node cluster, with
an IP range of `10.30.0.13-10.30.0.17`.

{{< img src="https://octetz.s3.us-east-2.amazonaws.com/routes.png" width="750px"
>}}

Every colored line represents a peering connection we'd expect in this cluster.
These connections can be surfaced by downloading
[calicoctl](https://github.com/projectcalico/calicoctl/releases) and running
`sudo calicoctl node status` on a node. The example below shows the output from
`10.30.0.15` in our example.

```
sudo calicoctl node status

Calico process is running.

IPv4 BGP status
+--------------+-------------------+-------+----------+--------------------------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |              INFO              |
+--------------+-------------------+-------+----------+--------------------------------+
| 10.30.0.17   | node-to-node mesh | up    | 01:17:08 | Established                    |
| 10.30.0.16   | node-to-node mesh | up    | 01:17:07 | Established                    |
| 10.30.0.14   | node-to-node mesh | up    | 01:29:06 | Established                    |
| 10.30.0.13   | node-to-node mesh | up    | 01:29:06 | Established                    |
+--------------+-------------------+-------+----------+--------------------------------+
```

This default behavior prevents us from worrying about upstream routers and
BGP-configuration complexity. However, once our cluster grows to hundreds of
nodes, we may find this node-to-node mesh to be no longer scalable. Route
reflectors provide a solution to this. Since Calico 3, `calico/node` can act as
a reflector. Introducing 2 `calico/node` pods or containers as route reflectors
would change the peering relationship to the following.

{{< img src="https://octetz.s3.us-east-2.amazonaws.com/route-reflection.png"
width="600px" >}}

Calico makes achieving the above easy. We have 3 options to choose from.

1. Dedicate Kubernetes node(s) to be route reflectors.

1. Run `calico/node` as a container on non-Kubernetes host(s).

1. Run a different reflector, such as a dedicated
   [BIRD](https://bird.network.cz) binary, and setup Calico to peer with it.

Trade-offs must be weighed between the options. Since configuration of option 1
& 2 are nearly identical and option 1 doesn't require additional hosts, we'll
choose option 1 for demonstrating how reflection is configured. To do this we'll
perform the following steps.

1. Select and configure `Node` resources to act as reflectors.

1. Setup `BGPPeering` configurations to talk to reflectors.

1. Disable node-to-node mesh.

## Configuring Nodes

First, we need to select the Nodes in our cluster to act as route reflectors.
You may choose to taint these nodes to ensure other workloads don't run on them.

List nodes in the cluster.

```
kubectl get no -o wide

NAME    STATUS   ROLES    AGE     VERSION   INTERNAL-IP
qtwtv   Ready    <none>   4h49m   v1.13.0   10.30.0.17  
rxgks   Ready    <none>   4h49m   v1.13.0   10.30.0.16  
uqwst   Ready    <none>   4h49m   v1.13.0   10.30.0.14  
volwl   Ready    <none>   4h49m   v1.13.0   10.30.0.15  
zyisy   Ready    master   4h50m   v1.13.0   10.30.0.13  
```

Let's choose `zyisy` and `rxgks` as our reflector nodes.

Download `calicoctl` on the host.

```
wget https://github.com/projectcalico/calicoctl/releases/download/v3.4.0/calicoctl-linux-amd64
chmod +x calicoctl-linux-amd64
sudo mv calicoctl-linux-amd64 /usr/local/bin/calicoctl
```

Export the `Node` resource of our chosen nodes to the local file system.

```
calicoctl get node zyisy --export -o yaml > zyisy.yaml
calicoctl get node rxgks --export -o yaml > rxgks.yaml
```

Edit each node to include a `spec.bgp.routeReflectorClusterID: 1.0.0.1` and a
`metadata.labels.router-reflector: true`  An updated version of node `zyisy` is
below.

```
apiVersion: projectcalico.org/v3
kind: Node
metadata:
  name: zyisy
  labels:
    route-reflector: true
spec:
  bgp:
    ipv4Address: 10.30.0.13/22
    ipv4IPIPTunnelAddr: 192.168.0.1
    routeReflectorClusterID: 1.0.0.1
```

The `routeReflectorClusterID` represents the BGP router's cluster id, this is
**not** synonymous with a Kubernetes cluster identifier. Determining whether
reflectors should share cluster ids may depend on your topology. You should read
about reflector peering and the implications of shared / unique cluster ids to
make an informed decision.

Replace the existing `Node` resources with the updated ones.

```
calicoctl replace -f zyisy.yaml
Successfully replaced 1 'Node' resource(s)

calicoctl replace -f rxgks.yaml
Successfully replaced 1 'Node' resource(s)
```

## Configure BGP Peering

The
[BGPPeer](https://docs.projectcalico.org/v3.4/reference/calicoctl/resources/bgppeer)
resource defines what nodes peer. This is also commonly used when peering
Calico's network with your data center fabric by configuring peering to Top of
Rack (ToR) routers.

We can make use of the added label `route-reflector: true` to easily setup a
dynamic detection of reflector nodes should peer with.

Add the following node peering connection to ensure `calico/node` instance peer
with the reflector instances.

```
kind: BGPPeer
apiVersion: projectcalico.org/v3
metadata:
  name: node-peer-to-rr
spec:
  nodeSelector: !has(route-reflector)
  peerSelector: has(route-reflector)
```

Add peering between the RouteReflectors themselves.

```
kind: BGPPeer
apiVersion: projectcalico.org/v3
metadata:
  name: rr-to-rr-peer
spec:
  nodeSelector: has(route-reflector)
  peerSelector: has(route-reflector)
```

## Disable node-to-node Mesh

Lastly, we must turn off node-to-node mesh ensuring nodes are only peering with
the reflectors they're configured to. This requires altering or adding a default
`BGPConfiguration`.

Check for an existing config, if one exists, modify/replace the existing,
otherwise follow steps to create a new one.

```
calicoctl get bgpconfig default
```

Create a `BGPConfiguration` with `nodeToNodeMeshEnabled: false` and an
Autonomous System number (`asNumber`) of `63400`.

```
apiVersion: projectcalico.org/v3
kind: BGPConfiguration
metadata:
  name: default
spec:
  logSeverityScreen: Info
  nodeToNodeMeshEnabled: false
  asNumber: 63400
```

Your asNumber may vary based on other BGP configurations throughout your data center(s).

On a non-reflector node, re-run `node status`.

```
sudo calicoctl node status

Calico process is running.

IPv4 BGP status
+--------------+-----------+-------+----------+-------------+
| PEER ADDRESS | PEER TYPE | STATE |  SINCE   |    INFO     |
+--------------+-----------+-------+----------+-------------+
| 10.30.0.13   | global    | up    | 03:52:51 | Established |
| 10.30.0.16   | global    | up    | 03:54:11 | Established |
+--------------+-----------+-------+----------+-------------+

IPv6 BGP status
No IPv6 peers found.
```

We can now see `zyisy: 10.30.0.13` and `rxgks: 10.30.0.16` are the reflectors
this node is peering with! From here, validate network connectivity between
pods.

## Additional Thoughts and Considerations

I hope you found this post helpful in understanding the configuration of route
reflectors with Calico! Below are some additional thoughts and considerations to
leave you with.

* Remember that when reflector nodes fail or get removed, we must replace them.
* It'd be cool if we one day there existed an operator / controller that can
  handle the assignment of a reflectors to nodes  based on scaled and topology!
* You may need to consider a different `asNumber` than the one used here.
* `routeReflectorClusterID` between routeReflectors may vary.
