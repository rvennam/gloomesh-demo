```bash
export CLUSTER1=gke_ambient_one
export CLUSTER2=gke_ambient_two
export ISTIOCTL=/Users/ramvennam/istio-1.24.3-solo/bin/istioctl
```

# Init
```bash
helm upgrade -i gloo-platform-crds gloo-platform/gloo-platform-crds -n gloo-mesh --create-namespace --version=2.7.0
helm upgrade -i gloo-platform gloo-platform/gloo-platform -n gloo-mesh --version 2.7.0 --values mgmt-values.yaml \
  --set licensing.glooMeshLicenseKey=$GLOO_MESH_LICENSE_KEY

export TELEMETRY_GATEWAY_ADDRESS=$(kubectl get svc -n gloo-mesh gloo-telemetry-gateway --context $CLUSTER1 -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}"):4317
meshctl cluster register cluster2  --kubecontext $CLUSTER1 --profiles gloo-core-agent --remote-context $CLUSTER2 --telemetry-server-address $TELEMETRY_GATEWAY_ADDRESS

DEV_BUILD_VERSION="2.8.0-beta1-2025-03-11-main-e755d336f4"
DEV_BUILD_VERSION="2.8.0-beta1-2025-03-16-main-d28a70b1b5"
DEV_BUCKET="https://storage.googleapis.com/gloo-platform-dev"


helm repo add gloo-platform-dev $DEV_BUCKET/platform-charts/helm-charts
helm repo update

helm upgrade -i gloo-platform-crds gloo-platform-dev/gloo-platform-crds -n gloo-mesh --create-namespace --version=$DEV_BUILD_VERSION
helm upgrade -i gloo-platform gloo-platform-dev/gloo-platform -n gloo-mesh --version $DEV_BUILD_VERSION --values mgmt-values.yaml \
  --set licensing.glooMeshLicenseKey=$GLOO_MESH_LICENSE_KEY --set licensing.glooGatewayLicenseKey=$GLOO_GATEWAY_LICENSE_KEY

function create_cacerts_secret() {
  context=${1:?context}
  cluster=${2:?cluster}
  kubectl --context=${context} create ns istio-system || true
  kubectl --context=${context} create ns istio-gateways || true
  kubectl --context=${context} create secret generic cacerts -n istio-system \
    --from-file=$HOME/istio-1.24.2/certs/${cluster}/ca-cert.pem \
    --from-file=$HOME/istio-1.24.2/certs/${cluster}/ca-key.pem \
    --from-file=$HOME/istio-1.24.2/certs/${cluster}/root-cert.pem \
    --from-file=$HOME/istio-1.24.2/certs/${cluster}/cert-chain.pem
}

create_cacerts_secret ${CLUSTER1} cluster1
create_cacerts_secret ${CLUSTER2} cluster2

for context in ${CLUSTER1} ${CLUSTER2}; do
  helm upgrade --install --kube-context=${context} gloo-operator oci://us-docker.pkg.dev/solo-public/gloo-operator-helm/gloo-operator --version 0.1.0-beta.3 -n gloo-system --create-namespace &
done

helm repo add glooe https://storage.googleapis.com/gloo-ee-helm
helm repo update

helm upgrade --install -n gloo-system gloo glooe/gloo-ee \
--create-namespace \
--version 1.19.0-beta2 \
--kube-context ${CLUSTER1} \
--set-string license_key=$GLOO_GATEWAY_LICENSE_KEY \
-f ./gg-values.yaml
```



# GG to Ambient MC
```yaml
kind: Gateway
apiVersion: gateway.networking.k8s.io/v1
metadata:
  name: http
  namespace: gloo-system
spec:
  gatewayClassName: gloo-gateway
  listeners:
  - protocol: HTTP
    port: 80
    name: http
    allowedRoutes:
      namespaces:
        from: All
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: bookinfo-gg
  namespace: bookinfo
spec:
  parentRefs:
  - name: http
    namespace: gloo-system
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
    backendRefs:
    - name: productpage
      port: 9080

```

```
for context in ${CLUSTER1} ${CLUSTER2}; do
  kubectl --context ${context}  label namespace bookinfo istio.io/dataplane-mode=ambient
  kubectl --context ${context}  label namespace httpbin istio-injection=enabled
  kubectl --context ${context}  delete pods -n httpbin --all
done
```


# RESET

```bash
for context in ${CLUSTER1} ${CLUSTER2}; do
  kubectl --context ${context}  delete Gateways -n istio-gateways --all
  kubectl --context=${context} delete ns bookinfo
  kubectl --context=${context} delete ns httpbin
done

for context in ${CLUSTER1} ${CLUSTER2}; do
  kubectl --context ${context} create ns bookinfo 
  kubectl --context ${context} apply -n bookinfo -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/bookinfo/platform/kube/bookinfo.yaml
  kubectl --context ${context} apply -n bookinfo -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/bookinfo/platform/kube/bookinfo-versions.yaml
done

for context in ${CLUSTER1} ${CLUSTER2}; do
  kubectl --context ${context} create ns httpbin 
done

kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/sleep/sleep.yaml --context ${CLUSTER1} -n httpbin
kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/httpbin/httpbin.yaml --context ${CLUSTER1} -n httpbin
kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/httpbin/httpbin.yaml --context ${CLUSTER2} -n httpbin

for context in ${CLUSTER1} ${CLUSTER2}; do
  kubectl --context ${context}  label namespace bookinfo istio.io/dataplane-mode=ambient
  kubectl --context ${context}  label namespace httpbin istio-injection=enabled
  kubectl --context ${context}  delete pods -n httpbin --all
done

kubectl --context=${CLUSTER1} apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: bookinfo-gg
  namespace: bookinfo
spec:
  parentRefs:
  - name: http
    namespace: gloo-system
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
    backendRefs:
    - name: productpage
      port: 9080
EOF
```