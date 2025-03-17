httpbin 

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: distributed-gateway
  namespace: gw-distro
  labels:
    example: gw-distribute
  annotations:
    gloo.solo.io/distribute-to: "*"
spec:
  gatewayClassName: gloo-gateway-distribute
  listeners:
  - protocol: HTTP
    port: 8080
    hostname: mydomain.com
    name: http
    allowedRoutes:
      namespaces:
        from: All
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: httpbin-mydomain
  namespace: gw-distro
  labels:
    example: gw-distribute
spec:
  parentRefs:
    - name: distributed-gateway
      namespace: gw-distro
  rules:
    - backendRefs:
      - name: httpbin
        kind: Upstream
        group: gloo.solo.io
---
apiVersion: gloo.solo.io/v1
kind: Upstream
metadata:
  name: httpbin
  namespace: gw-distro
spec:
  kube:
    serviceName: httpbin
    serviceNamespace: httpbin
    servicePort: 8000
```