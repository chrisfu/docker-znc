# ZNC for Kubernetes

Run the [ZNC][] IRC Bouncer within Kubernetes, exposing a port of your choice
between the standard `nodePort` TCP range of 30000-32767. This set of manifests
is provided as an example, and it is expected that users would alter and extend
it to fit their use case.

This set of manifests uses the `chrisfu/znc` image found at [Docker Hub][].

[ZNC]: http://znc.in
[Docker Hub]: https://hub.docker.com/

## Prerequisites

1. A working [Kubernetes][] cluster.
2. A correctly provisioned PersistentStorage class. For this example we use the
closed-source developer edition of [Portworx][], which is perfectly fine if
you're looking for a simple, elegant solution with a maximum of 3 storage
workers.

[Kubernetes]: https://kubernetes.io/
[Portworx]: https://github.com/portworx/px-dev

## Deployment

To perform the initial deployment, it is as simple as:

    kubectl -f create znc/

This will create the `Service`, `Deployment` and `PersistentVolumeClaim`
manifests for ZNC. Within a minute or so the ZNC service will be available when
hitting the address of any of your Kubernetes workers (thanks to `kube-proxy`)
on the port defined in the `nodePort` key of `znc/service.yml`.

Be careful when reapplying the `znc/pvc.yml` manifest, as incorrect usage could
result in your persistent volume being destroyed and recreated afresh!
