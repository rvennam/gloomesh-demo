# <center>Gloo Platform POC</center>

![Gloo Platform UI](./images/gloo-mesh.png)

[Gloo Platform](https://www.solo.io/products/gloo-platform/) integrates API gateway, API management, Istio service mesh and cloud-native networking into a unified application networking platform. It across single or many clusters and across multiple teams. At the core, it's enterprise [Istio](https://istio.io) with production support, N-4 support, CVE patching, FIPS builds, and a multi-cluster operational management plane to simplify running a service mesh across multiple clusters or a hybrid deployment. 

Gloo Platform also has features around multi-tenancy, global failover and routing, observability, and east-west rate limiting and policy enforcement (through AuthZ/AuthN plugins). 

![Gloo Platform Value](./images/gloo-platform-value.png)

## Before You Start

Before starting this POC workshop, its important that are setup with the right components and tooling in place to ensure success. 

### Supporting Tools

The below tools are designed to help you understand and debug your environment. 

* istioctl - Istio debugging tool `curl -L https://istio.io/downloadIstio | sh -`
* meshctl - Solo.io Gloo Platform CLI - `curl -sL https://run.solo.io/meshctl/install | sh`

### Documentation and Examples

* Gloo Platform Docs - https://docs.solo.io/gloo-mesh-enterprise/

Solo.io documentation is great for getting to know Gloo Platform. From examples to API documentation you can search and find help. It is recommended that a POC user read through the Gloo Platform concepts before getting started. 

* Gloo Platform Concepts - https://docs.solo.io/gloo-mesh-enterprise/latest/concepts/
* API Reference - https://docs.solo.io/gloo-mesh-enterprise/latest/reference/api/

### Cluster Setup

![](./images/3-cluster-setup.png)

This POC depends on our typicall "3 cluster" setup where one cluster will be used for administration of the other two service mesh based clusters. 

**Requirements**
* Each cluster can reach load balancers attached to the other clusters by either internal or exteral networking
* Cluster Resource Sizing
  * Management Cluster:
    - Nodes: 2
    - CPU Per Node: 4vCPU
    - Memory Per Node: 16Gi
  * Each Remote Cluster:
    - Nodes: 2
    - CPU Per Node: 4vCPU
    - Memory Per Node: 16Gi

### Private Image Repository

Some organizations do not allow public docker repository access and need to download the images and upload them to a private repository. 

* To view the images that are used in this POC, run `cat images.txt` 

The easiest way to get the images in your repository is to pull the listed images, retag them to your internal registry and push. 


### Helm charts

The following helm charts are used in this POC or may be needed depending on your use cases.

```sh
# required
helm repo add gloo-platform https://storage.googleapis.com/gloo-platform/helm-charts
helm pull oci://us-central1-docker.pkg.dev/solo-test-236622/solo-demos/onlineboutique

# Optional addons
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo add jetstack https://charts.jetstack.io
helm repo update
```