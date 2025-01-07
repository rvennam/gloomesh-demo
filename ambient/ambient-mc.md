# Gloo Ambient Multi-Cluster Demo
## Create 2 Clusters and set env vars to their context
```bash
export CLUSTER1=gke_field-engineering-us_us-central1-c_rvennam-ilm
export CLUSTER2=gke_field-engineering-us_us-central1-c_rvennam-ilm-2
export ISTIOCTL=/Users/ramvennam/Downloads/istioctl
```


Set up credentials for images
```
cd ~/Downloads
for context in ${CLUSTER1} ${CLUSTER2}; do
  for namespace in gloo-system istio-system kube-system istio-gateways bookinfo; do
    kubectl --context=${context} create secret docker-registry regcred \
      --docker-server=https://us-docker.pkg.dev \
      --docker-username=_json_key \
      --docker-password="$(cat secret.json)" \
      --docker-email=therealrameth@gmail.com \
      -n ${namespace}
  done
done
```

## Install Istio using Gloo Operator
```bash
helm install --kube-context=${CLUSTER1} gloo-operator oci://us-docker.pkg.dev/solo-public/gloo-operator-helm/gloo-operator --version 0.1.0-beta.1 -n gloo-system --create-namespace
helm install --kube-context=${CLUSTER2} gloo-operator oci://us-docker.pkg.dev/solo-public/gloo-operator-helm/gloo-operator --version 0.1.0-beta.1 -n gloo-system --create-namespace
```

```bash
kubectl --context=${CLUSTER1} apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
kubectl --context=${CLUSTER2} apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
```


Use the `ServiceMeshController` API to install Istio on both clusters

```bash
kubectl --context=${CLUSTER1} apply -f - <<EOF
apiVersion: operator.gloo.solo.io/v1
kind: ServiceMeshController
metadata:
  name: istio
spec:
  version: 1.24-alpha.36d8d1c094bdb946f793b4cf5e07167df5faaad8-internal
  installNamespace: istio-system
  cluster: cluster1
  repository:
    url: oci://us-docker.pkg.dev/istio-enterprise-private/internal-istio-helm
    secrets:
      - name: regcred
        namespace: gloo-system
  image:
    repository: us-docker.pkg.dev/istio-enterprise-private/internal-istio-builds
    secrets:
      - name: regcred
EOF
```

```bash
kubectl --context=${CLUSTER2} apply -f - <<EOF
apiVersion: operator.gloo.solo.io/v1
kind: ServiceMeshController
metadata:
  name: istio
spec:
  version: 1.24-alpha.36d8d1c094bdb946f793b4cf5e07167df5faaad8-internal
  installNamespace: istio-system
  cluster: cluster2
  repository:
    url: oci://us-docker.pkg.dev/istio-enterprise-private/internal-istio-helm
    secrets:
      - name: regcred
        namespace: gloo-system
  image:
    repository: us-docker.pkg.dev/istio-enterprise-private/internal-istio-builds
    secrets:
      - name: regcred
EOF
```

### Configure Trust
```bash
cd ~/istio-1.24.2
```bash
function create_cacerts_secret() {
  context=${1:?context}
  cluster=${2:?cluster}
  kubectl --context=${context} create secret generic cacerts -n istio-system \
    --from-file=certs/${cluster}/ca-cert.pem \
    --from-file=certs/${cluster}/ca-key.pem \
    --from-file=certs/${cluster}/root-cert.pem \
    --from-file=certs/${cluster}/cert-chain.pem
}

create_cacerts_secret ${CLUSTER1} cluster1
create_cacerts_secret ${CLUSTER2} cluster2
```


```bash
kubectl --context=${CLUSTER1} label namespace istio-system topology.istio.io/network=cluster1 --overwrite
kubectl --context=${CLUSTER2} label namespace istio-system topology.istio.io/network=cluster2 --overwrite

kubectl --context=${CLUSTER1} create namespace istio-gateways || true
kubectl --context=${CLUSTER2} create namespace istio-gateways || true

$ISTIOCTL --context=${CLUSTER1} multicluster expose --wait -n istio-gateways
$ISTIOCTL --context=${CLUSTER2} multicluster expose --wait -n istio-gateways

```

## Link the clusters together

## This doesn't work yet because of revisions:
```bash
$ISTIOCTL multicluster link --contexts=$CLUSTER1,$CLUSTER2 -n istio-gateways
```

## Workaround:

```bash
function link() {
  from=${1:?from}
  to=${2:?to}
  fromname=${3:?fromname}
  local ip="$(kubectl --context $from -n istio-gateways get service istio-eastwest -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
  local typ="IPAddress"
  if [[ "${ip}" == "" ]]; then
    ip="$(kubectl --context $from -n istio-gateways get service istio-eastwest -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
    typ="Hostname"
  fi
  cat <<EOF | kubectl apply -f - --context $to
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: remote-${fromname}
  namespace: istio-gateways
  annotations:
    gateway.istio.io/service-account: istio-eastwest
    gateway.istio.io/trust-domain: ${fromname}
  labels:
    topology.istio.io/network: ${fromname}
spec:
  gatewayClassName: istio-remote
  addresses:
  - value: "${ip}"
    type: "${typ}"
  listeners:
  - name: cross-network
    port: 15008
    protocol: HBONE
EOF
}


link $CLUSTER1 $CLUSTER2 cluster1
link $CLUSTER2 $CLUSTER1 cluster2
```

# Install Bookinfo sample on both clusters
Run the following commands to deploy the bookinfo application on the clusters:


```bash
for context in ${CLUSTER1} ${CLUSTER2}; do
  kubectl --context ${context} create ns bookinfo
  kubectl --context ${context} label namespace bookinfo istio.io/dataplane-mode=ambient
  kubectl --context ${context} apply -n bookinfo -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/bookinfo/platform/kube/bookinfo.yaml
  kubectl --context ${context}  -n bookinfo label service productpage solo.io/service-scope=global
  kubectl --context ${context}  -n bookinfo annotate service productpage  networking.istio.io/traffic-distribution=Any
done
```




```bash
kubectl --context ${CLUSTER1}  -n bookinfo label service reviews solo.io/service-scope=global
kubectl --context ${CLUSTER2}  -n bookinfo label service reviews solo.io/service-scope=global
kubectl --context ${CLUSTER1}  -n bookinfo annotate service reviews  networking.istio.io/traffic-distribution=Any
kubectl --context ${CLUSTER2}  -n bookinfo annotate service reviews  networking.istio.io/traffic-distribution=Any
```

```bash
while true; do
    curl reviews.bookinfo.mesh.internal:9080/reviews/1
    echo ""
    sleep 1
done


while true; do
    curl reviews:9080/reviews/1
    sleep 1
done
```



GMC:
```bash
export MGMT_CLUSTER=mgmt
export REMOTE_CLUSTER1=cluster1
export REMOTE_CLUSTER2=cluster2

export MGMT_CONTEXT=$CLUSTER1
export REMOTE_CONTEXT1=$CLUSTER1
export REMOTE_CONTEXT2=$CLUSTER2

meshctl install --profiles gloo-core-single-cluster \
--kubecontext $MGMT_CONTEXT \
--set common.cluster=cluster1 \
--set licensing.glooMeshCoreLicenseKey=$GLOO_MESH_CORE_LICENSE_KEY \
--set telemetryGateway.enabled=true
```


```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: bookinfo-gateway
  namespace: bookinfo
spec:
  gatewayClassName: istio
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: bookinfo
  namespace: bookinfo
spec:
  parentRefs:
  - name: bookinfo-gateway
  rules:
  - matches:
    - path:
        type: Exact
        value: /productpage
    - path:
        type: PathPrefix
        value: /static
    - path:
        type: Exact
        value: /login
    - path:
        type: Exact
        value: /logout
    - path:
        type: PathPrefix
        value: /api/v1/products
    # backendRefs:
    # - name: productpage
    #   port: 9080
    backendRefs:
    - kind: Hostname
      group: networking.istio.io
      name: productpage.bookinfo.mesh.internal
      port: 9080

```