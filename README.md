# crane-container

A containerized GitOps tool based on [Konveyor's Crane CLI](https://github.com/konveyor/crane), which exports YAML in bulk from Kubernetes to the local filesystem.

## Build

You can build the container with any tooling that understands Dockerfiles:

```sh
podman build . -t crane
```

## GitOps Export Usage

### Quickstart

You can run the container with any CRI compatible runtime, providing required mount points and additional options if needed:

```sh
podman run -v /home/me/.kube:/root/.kube -v /home/me/my-local-gitops-dir:/data -e CRANE_ADDITIONAL_OPTIONS="--namespace=bar" localhost/crane
```

After crane completes the export, you should have a local directory structure of YAML files you can clean up/commit to git:

```sh
ls /home/me/my-local-gitops-dir
```

### Interactive

Alternatively, hop into the container and run `crane` commands interactively:

```sh
podman run --rm -it --entrypoint=/bin/sh -v /home/me/.kube:/root/.kube -v /home/me/my-local-githops-dir:/data localhost/crane
```

### Configuration

If not running interactively, there's an entrypoint script configured by environment variables:

| env | description | default |
|---|---|---|
| EXPORT_DIR | a path under `/data` in the container filesystem to place exported YAML manifests | "crane-export" |
| CRANE_ADDITIONAL_OPTIONS | a string of options interpreted literally by `crane`, e.g. `--namespace=foo --context=development-cluster` | "" |

### Volumes

No matter how you run the container (entrypoint/interactive), you need to mount in your kubeconfig and (optionally?) provide a local mounting to where `crane` will export the YAML manifests to your local filesystem:

```sh
podman run -v /home/me/.kube:/root/.kube -v /home/me/my-local-githops-dir:/data localhost/crane
```