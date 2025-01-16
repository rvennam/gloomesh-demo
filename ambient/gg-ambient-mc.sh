export CLUSTER1=gke_ambient_one
export CLUSTER2=gke_ambient_two
export ISTIOCTL=/Users/ramvennam/Downloads/istioctl

helm repo add glooe https://storage.googleapis.com/gloo-ee-helm
helm repo update

helm upgrade --install -n gloo-system gloo glooe/gloo-ee \
--create-namespace \
--version 1.18.2 \
--set-string license_key=$GLOO_GATEWAY_LICENSE_KEY \
-f -<<EOF
gloo:
  discovery:
    enabled: false
  gatewayProxies:
    gatewayProxy:
      disabled: true
  kubeGateway:
    enabled: true
  gloo:
    disableLeaderElection: true
gloo-fed:
  enabled: false
  glooFedApiserver:
    enable: false
grafana:
  defaultInstallationEnabled: false
observability:
  enabled: false
prometheus:
  enabled: false
ambient:
  waypoint:
    enabled: true
EOF


kubectl --context ${CLUSTER1} set image Deployment/gloo -n gloo-system gloo=slandow/gloo-ee:ambient-multinet-fix-automtls

# Edit the Settings to set removeUnusedFilters to true

kubectl --context ${CLUSTER1} -n httpbin apply -f https://raw.githubusercontent.com/solo-io/gloo-mesh-use-cases/main/policy-demo/httpbin.yaml

kubectl --context ${CLUSTER1} apply -f - <<EOF
apiVersion: gateway.gloo.solo.io/v1alpha1
kind: GatewayParameters
metadata:
  name: gloo-gateway-override
  namespace: gloo-system
spec:
  kube:
    deployment:
      replicas: 1
    service:
      type: LoadBalancer
    envoyContainer:
      image:
        registry: slandow
        repository: gloo-ee-envoy-wrapper
        tag: proxy-tlv
---
kind: Gateway
apiVersion: gateway.networking.k8s.io/v1
metadata:
  name: http
  namespace: gloo-system
  annotations:
    gateway.gloo.solo.io/gateway-parameters-name: gloo-gateway-override
spec:
  gatewayClassName: gloo-gateway
  listeners:
  - protocol: HTTP
    port: 8080
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
EOF