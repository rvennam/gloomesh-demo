kubectl delete kubernetescluster remotecluster1 -n gloo-mesh
kubectl delete ns gloo-mesh --context rvennam-us-east-remote1

kubectl delete kubernetescluster remotecluster2 -n gloo-mesh
kubectl delete ns gloo-mesh --context rvennam-us-east-remote2

helm uninstall gloo-mesh-enterprise --namespace gloo-mesh
kubectl delete ns gloo-mesh