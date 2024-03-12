# Single Cluster
## Visit BookInfo

# View Registered Clusters
kubectl get kubernetesclusters

# View meshes
meshctl describe meshes

# Deploy reviews-v2 on CLUSTER1
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/bookinfo/platform/kube/bookinfo.yaml -l app=reviews,version=v2

# Traffic Policy - Single Cluster
3-trafficpolicy-single-cluster.yaml

# Dashboard
meshctl dashboard

# Clean up

# Remove reviews from cluster1
kubectl delete deploy reviews-v2 --context $CLUSTER1
kubectl delete TrafficPolicy simple-cluster1

---
# Istio Lifecycle

## Cleanup
k delete -n gloo-mesh IstioInstallation --all
istioctl x uninstall --purge

# install.yaml
k rollout restart deploy




---
# Multiple clusters

# Diagram

# cacerts

# Group Meshes
meshctl describe mesh
kubectl apply -f 0-virtualmesh.yaml

# Workloads
meshctl describe workload

# Dashboard
meshctl dashboard

# Secrets

# Visit BookInfo

# Access Policy
accesspolicy-productpage-defaultns.yaml
accesspolicy-ingress-productpage.yaml

# Service Entries on remotecluster1

# Traffic Policies and Access Policies
4-trafficpolicy-multi-cluster.yaml
k delete trafficpolicy reviews-tp

# Failover
Zones
reviews-failover.yaml

# Break reviews-v1
kubectl patch deploy reviews-v1 --patch '{"spec": {"template": {"spec": {"containers": [{"name": "reviews","command": ["sleep", "20h"]}]}}}}'
kubectl patch deploy reviews-v2 --patch '{"spec": {"template": {"spec": {"containers": [{"name": "reviews","command": ["sleep", "20h"]}]}}}}'

kubectl patch deploy reviews-v3 --patch '{"spec": {"template": {"spec": {"containers": [{"name": "reviews","command": ["sleep", "20h"]}]}}}}'


# Fix reviews-v1
kubectl patch deployment reviews-v1  --type json   -p '[{"op": "remove", "path": "/spec/template/spec/containers/0/command"}]'
kubectl patch deployment reviews-v2  --type json   -p '[{"op": "remove", "path": "/spec/template/spec/containers/0/command"}]'
kubectl patch deployment reviews-v3  --type json   -p '[{"op": "remove", "path": "/spec/template/spec/containers/0/command"}]'

# Prometheus
kubectl -n gloo-mesh port-forward deploy/prometheus-server 9090
sum(
  increase(
    istio_requests_total{
    }[2m]
  )
) by (
  gm_workload_ref,
  gm_destination_workload_ref,
  response_code,
)

# Access Log
kubectl apply -f logging/accesslog-reviews.yaml

