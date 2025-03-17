source .env
for context in ${CLUSTER1} ${CLUSTER2}; do
  helm uninstall ztunnel -n istio-system --kube-context=${context}
  helm uninstall istiod -n istio-system --kube-context=${context}
  helm uninstall istio-cni -n istio-system --kube-context=${context}
  helm uninstall istio-base -n istio-system --kube-context=${context}
  kubectl --context=${context} scale deploy gloo-operator --replicas=1 -n gloo-system
  kubectl --context=${context} delete gateways --all -n istio-gateways
  kubectl --context=${context} delete gateways --all -n bookinfo
  kubectl --context=${context} delete smc --all
  sleep 10
  helm uninstall gloo-operator -n gloo-system --kube-context=${context}
  sleep 5
  kubectl --context=${context} delete ns istio-gateways 
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