source .env

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
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: httpbin-good
  namespace: httpbin
spec:
  parentRefs:
    - name: http
      namespace: gloo-system
  rules:
    - matches:
        - path:
            type: Exact
            value: /headers
      backendRefs:
        - name: httpbin
          port: 8000
EOF

