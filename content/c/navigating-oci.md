---
title: "Navigating OCI Artifacts and Images"
weight: 9910
description: OCI has long been the standard format of container images. Over time this standard has grown to support additional artifacts. As both the types of OCI-compliant artifacts and images have grown, it is important to have tooling enabling discovery and introspection. This post covers the commend line tool crane and how it can be used for discovery, introspection, and copying OCI assets.
date: 2022-06-22
images:
- https://files.joshrosso.com/img/site/navigating-oci/twitter-title-navigating-oci.png
---

# Navigating OCI Artifacts and Images

{{< youtube XbUAPlZi0x0 >}}

OCI's [image
specification](https://github.com/opencontainers/image-spec/blob/main/spec.md)
defines the contents and conventions of container images. This vendor-neutral
standard became prevalent as the number of container runtimes increased[^1],
demanding compatibility beyond Docker. As container usage has grown, so has the
need for assets that exist ancillary to containers. Examples include [Open Policy
Agent
policies](https://www.openpolicyagent.org/docs/latest/configuration/#example-1),
[Helm charts](https://helm.sh/blog/storing-charts-in-oci/), and [Carvel package
bundles](https://carvel.dev/imgpkg/docs/v0.29.0). These assets do not contain a
filesystem, which is unaligned with the [OCI image
specification](https://github.com/opencontainers/image-spec/blob/main/image-layout.md).
As such, a need grew to define what is known as an [OCI
artifact](https://github.com/opencontainers/artifacts). Artifacts offer a more
generic definition[^2] for what can be stored in an OCI registry and consumed by
clients.

[^1]: [YouTube: Container Runtime and Image Format Standards - What it Means to be “OCI-Certified” [I] - Jeff Borek](https://www.youtube.com/watch?v=-BfhZiJzLeA)
[^2]: [Medium: OCI Artifacts Explained - Dan Lorenc](https://dlorenc.medium.com/oci-artifacts-explained-8f4a77945c13)


All this is to say that the number of OCI-compliant assets are growing and
taking on new forms. In this new world, it's helpful to have tooling to
introspect and work with remote OCI assets. Bonus points if this tooling is
designed to work as a client without being a fully-baked container runtime. In
this post, I'll be talking about
[crane](https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane.md),
which is my Swiss Army knife for navigating OCI artifacts and images.

## Tooling

While this post is about [crane](https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane.md), there are several tools capable of interacting with OCI artifacts. Examples include:

* [**`skopeo`**](https://github.com/containers/skopeo): Solid features for airgapped
  (sync between registry) use cases and introspection. Built on libraries found
  in [github.com/containers](https://github.com/containers), which happen to be
  the libraries used for [Podman](https://podman.io/). If you live in
  the Podman and/or RedHat ecosystem, this could be a good tool for you.
* [**`imgpkg`**](https://carvel.dev/imgpkg/): Has features around querying and
  introspecting OCI contents. This tooling shines in creating bundles
  of configuration that can be pushed to repositories. Combined with tools like
  `kbld`, it can build robust configurations enabling the locking of images
  referenced in configurations by their digest values[^3].

[^3]: [Carvel Docs: Generating resolution imgpkg lock output](https://carvel.dev/kbld/docs/v0.34.0/resolving/#generating-resolution-imgpkg-lock-output)

While the above (and some missing) tools are great, I grab for `crane` everytime
I'm working with the discovery and introspection of OCI assets. I find it's UX
to be solid, [commands to be feature
rich](https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane.md),
it is compatible with other Unix tooling, and it's underlying library
[go-containerregistry](https://github.com/google/go-containerregistry) is
easy to work with at the Go/library level.

If you wish to follow along with this post, [complete the Installation section of
crane's GitHub
page](https://github.com/google/go-containerregistry/tree/main/cmd/crane#installation).

## Discovery

First, you need a way to query the available tags on a given image. This can be
done using the `ls` command. For example, you can determine which `kube-apiserver`
images are available for the `1.24.x` release.

```sh
$ crane ls k8s.gcr.io/kube-apiserver | grep -i 1.24

sha256-c5113882ff00af29730f560f6567de63644f10c0d51f2416c55b8a6649abe282.sig
v1.24.0
v1.24.0-alpha.0
v1.24.0-alpha.1
v1.24.0-alpha.2
v1.24.0-alpha.3
v1.24.0-alpha.4
v1.24.0-beta.0
v1.24.0-rc.0
v1.24.0-rc.1
v1.24.1
v1.24.1-rc.0
v1.24.2
v1.24.2-rc.0
v1.24.3-rc.0
```

Now, let's figure out what is the [digest
value](https://github.com/opencontainers/image-spec/blob/main/descriptor.md#digests)
for the `v1.24.2` image.

```sh
$ crane digest k8s.gcr.io/kube-apiserver:v1.24.2

sha256:433696d8a90870c405fc2d42020aff0966fb3f1c59bdd1f5077f41335b327c9a
```

This digest is great, but doesn't tell the entire story. With the introduction
of the [OCI Image Index
Specification](https://github.com/opencontainers/image-spec/blob/main/image-index.md#oci-image-index-specification),
an asset may now contain a list that points to image manifests specific to
the platform and architecture of the target system. This feature enables all
platforms and architectures to point to the same tag, even though each needs to
run its own unique image, as detailed below.

{{< img class="center"
src="https://files.joshrosso.com/img/site/navigating-oci/multi-arch-pull.png" width=800" >}}

To understand which images are available, use the `manifest` command. This also identifies exactly where the image lives. Below are the images for Linux arm64 and amd64.

```txt
$ crane manifest k8s.gcr.io/kube-apiserver:v1.24.2 |\
    jq '.manifests[] | select(.platform.architecture=="amd64" or .platform.architecture=="arm64")'

{
  "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
  "size": 949,
  "digest": "sha256:e31b9dc1170027a5108e880ab1cdc32626fc7c9caf7676fd3af1ec31aad9d57e",
  "platform": {
    "architecture": "amd64",
    "os": "linux"
  }
}
{
  "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
  "size": 949,
  "digest": "sha256:a650cc38f804847dfa3a1043fa5c55d479be4e9c87be2ba1c3d58b803eec33e9",
  "platform": {
    "architecture": "arm64",
    "os": "linux"
  }
}
```


This image's manifest list implies there are multiple architectures available!
This means if a container runtime pulls down this tag, it'll use the manifest in
the list related to its architecture. For example, you'd expect `containerd`
running on an ARM Linux host to pull down the container with the starting digest
value of `a650cc`. It's also worth mentioning that if you ran `manifest` against
a tag that does not have multiple architectures, you'd get a list of each of the
container's layers along with each layer's digest value.

## Introspection

At some point, you'll want to look into the actual contents of the asset. To
start, you can look at the content of an image, namely `kube-apiserver`.
The `export` command will allow downloading the tarball locally. Using the
`-v` flag will give insight into how the image and its layers are being
resolved.

```sh
$ crane export -v k8s.gcr.io/kube-apiserver:v1.24.2 - | tar xv
```

There's too much output to paste here, but looking at the logs from the above
command, there are some key pieces of information. For example, note that
`export` is being run against the tag `v1.24.2`, which doesn't point to an
image, but instead a manifest pointing to platform/architecture specific images.

```txt
2022/06/21 14:09:27 <-- 200 https://k8s.gcr.io/v2/kube-apiserver/manifests/v1.24.2 (54.20325ms)
2022/06/21 14:09:27 HTTP/2.0 200 OK
Content-Length: 1694
Alt-Svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000,h3-Q050=":443"; ma=2592000,h3-Q046=":443"; ma=2592000,h3-Q043=":443"; ma=2592000,quic=":443"; ma=2592000; v="46,43"
Content-Type: application/vnd.docker.distribution.manifest.list.v2+json
Date: Tue, 21 Jun 2022 20:09:27 GMT
Docker-Content-Digest: sha256:433696d8a90870c405fc2d42020aff0966fb3f1c59bdd1f5077f41335b327c9a
Docker-Distribution-Api-Version: registry/2.0
Server: Docker Registry
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 0

{
   "schemaVersion": 2,
   "mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
   "manifests": [
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 949,
         "digest": "sha256:e31b9dc1170027a5108e880ab1cdc32626fc7c9caf7676fd3af1ec31aad9d57e",
         "platform": {
            "architecture": "amd64",
            "os": "linux"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 949,
         "digest": "sha256:a650cc38f804847dfa3a1043fa5c55d479be4e9c87be2ba1c3d58b803eec33e9",
         "platform": {
            "architecture": "arm64",
            "os": "linux"
         }
      }

      <-- other images retracted -->
   ]
}
```

Since my system is `amd64`, the image `e31b9d` is downloaded. If
you follow the logs you'll see that image is resolved and its manifest
containing references to its layers are located and then downloaded.

All that aside, you'll end up with the container contents on your local file
system.

```sh
$ ls

bin             etc             lib             run             tmp
boot            go-runner       proc            sbin            usr
dev             home            root            sys             var
```

From here you can easily inspect or modify its contents. For example, using `go`
tooling, its possible to determine exactly how the `kube-apiserver` binary was built.

```sh
$ go version -m usr/local/bin/kube-apiserver

usr/local/bin/kube-apiserver: go1.18.3
        path    k8s.io/kubernetes/cmd/kube-apiserver
        build   -asmflags=all=-trimpath=/workspace/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes
        build   -compiler=gc
        build   -gcflags="all=-trimpath=/workspace/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes "
        build   -ldflags="<-- ommited -->"
        build   -tags=selinux,notest
        build   CGO_ENABLED=0
        build   GOARCH=amd64
        build   GOOS=linux
        build   GOAMD64=v1
```

While great for introspecting container images, this is particularly useful when
you want to look into configuration stored in an OCI artifact. In the world of
[Carvel](https://carvel.dev), bundles of configuration can be stored in a
container registry. For example, the official [kpack
package](https://github.com/vmware-tanzu/package-for-kpack) is available at
`projects.registry.vmware.com/tce/kpack`. Using `ls` can reveal the version
`0.5.2` is available, and using `export`, you can look inside it.

```sh
$ crane export projects.registry.vmware.com/tce/kpack:0.5.2 - | tar xv

x .
x .imgpkg
x .imgpkg/images.yml
x config
x config/ca_cert.yaml
x config/kapp-config.yaml
x config/kp-config.yaml
x config/overlay.yaml
x config/proxy.yaml
x config/release
x config/release/release-0.5.2-rc.9.yaml
x config/schema.yaml
x config/version.yml
```

Inside `config/` there are multiple Kubernetes YAML files which are part of
this package bundle.

## Copying

A final use case to cover is replicating artifacts and images between
registries. One reason to do this is when you need to make an image available in
an internet-restricted environment. For example, when you need an image like
`k8s.gcr.io/kube-apiserver` to be available in your private registery that runs
in the same network as your clusters.

Copying an artifact or image is done using the `copy` command.

```sh
$ crane cp k8s.gcr.io/kube-apiserver:v1.24.2 index.docker.io/joshrosso/kube-apiserver:v1.24.2

2022/06/21 15:54:37 Copying from k8s.gcr.io/kube-apiserver:v1.24.2 to index.docker.io/joshrosso/kube-apiserver:v1.24.2
2022/06/21 15:54:39 pushed blob: sha256:d3377ffb7177cc4becce8a534d8547aca9530cb30fac9ebe479b31102f1ba503
2022/06/21 15:54:40 pushed blob: sha256:63186d32234e6ca9751e21f84bda2a6f5025eb3a44196f6dc4d0e9268ba7bbe0
2022/06/21 15:54:40 pushed blob: sha256:36698cfa5275e0bda70b0f864b7b174e0758ca122d8c6a54fb329d70082c73f8
2022/06/21 15:54:41 pushed blob: sha256:b71d10928c08172a60416656c3b43c55ccbe83255f704e9cb4108351994aaaed
<-- multiple logs removed -->
2022/06/21 15:55:12 index.docker.io/joshrosso/kube-apiserver:v1.24.2: digest: sha256:433696d8a90870c405fc2d42020aff0966fb3f1c59bdd1f5077f41335b327c9a size: 1694
```

During this `copy` operation, all platform/architecture combinations are copied
and each image digest is retained. You can verify this by running a `diff`
against the 2 manifests.

```sh
$ COPY=$(crane manifest index.docker.io/joshrosso/kube-apiserver:v1.24.2) \
    ORIG=$(crane manifest k8s.gcr.io/kube-apiserver:v1.24.2) \
    diff <(echo ${COPY}) <(echo ${ORIG})
```

## Shoutouts

This post is largely a callout to the awesomeness of
[google/go-containerregistry](https://github.com/google/go-containerregistry)
and its command line tool
[crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane).
Thanks to all the [maintainers and contributors](https://github.com/google/go-containerregistry/graphs/contributors) that have built these tools and worked on documentation.
