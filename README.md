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

## Export File Clean Up

> :warning: :warning:  :warning: ***You'll ultimately be responsible for your YAML audit before commiting anything to git, not any maintainers/contributors of this repo***. Examples below are given in good faith, they are not a comprehensive solution. :warning: :warning: :warning:    

After crane completes the export, you should have a local directory structure of YAML files you should manually clean up/commit to git. Cases for what should/shouldn't be commited will vary drastically by team. 

```sh
cd /home/me/my-local-gitops-dir

# Remove files generally automated by other controllers / stuff you likely don't want in git
find . -name "Build_*" -exec rm {} \;
find . -name "Endpoints_*" -exec rm {} \;
find . -name "ImageStreamTag_*" -exec rm {} \;
find . -name "ImageTag_*" -exec rm {} \;
find . -name "Pod_*" -exec rm {} \;
find . -name "ReplicaSet_*" -exec rm {} \;
find . -name "ReplicationController_*" -exec rm {} \;

# Remove admin stuff devs typically don't have access to edit (even though they can sometimes read them)
find . -name "ClusterServiceVersion_*" -exec rm {} \;
find . -name "LimitRange_*" -exec rm {} \;
```

:warning: ***Secrets exported from crane will not be encrypted only encoded! You should not commit them as-is to git (private or heaven-forbid public)!*** Be sure to check your ConfigMaps/Deployments/etc for sensitive information as well!

```sh
cd /home/me/my-local-gitops-dir
find . -name "Secret_*" -exec rm {} \;
```
