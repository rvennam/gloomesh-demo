export CLUSTER1=gke_ambient_one
export CLUSTER2=gke_ambient_two
export ISTIOCTL=/Users/ramvennam/Downloads/istioctl

for context in ${CLUSTER1} ${CLUSTER2}; do
  kubectl --context=${context} scale deploy gloo-operator --replicas=1 -n gloo-system
  kubectl --context=${context} delete smc --all
  kubectl --context=${context} delete ns istio-gateways 
  kubectl --context=${context} delete ns bookinfo
  sleep 10
  helm uninstall gloo-operator -n gloo-system --kube-context=${context}
  helm uninstall gloo -n gloo-system --kube-context=${context}
  meshctl uninstall --kubecontext=${context}
  kubectl --context=${context} delete ns istio-system 
  kubectl --context=${context} delete ns gloo-system
  kubectl --context=${context} delete ns gloo-mesh
done