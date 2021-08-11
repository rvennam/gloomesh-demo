
ENTERPRISE_NETWORKING_DOMAIN=$(kubectl get svc -n gloo-mesh enterprise-networking -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
ENTERPRISE_NETWORKING_PORT=$(kubectl -n gloo-mesh get service enterprise-networking -o jsonpath='{.spec.ports[?(@.name=="grpc")].port}')
ENTERPRISE_NETWORKING_ADDRESS=${ENTERPRISE_NETWORKING_DOMAIN}:${ENTERPRISE_NETWORKING_PORT}
echo $ENTERPRISE_NETWORKING_ADDRESS


# REGISTER CLUSTERS
meshctl cluster register enterprise \
  --mgmt-context=$MGMT_CONTEXT \
  --remote-context=$CLUSTER1 \
  --relay-server-address $ENTERPRISE_NETWORKING_ADDRESS \
  remotecluster1

meshctl cluster register enterprise \
  --mgmt-context=$MGMT_CONTEXT \
  --remote-context=$CLUSTER2 \
  --relay-server-address $ENTERPRISE_NETWORKING_ADDRESS \
  remotecluster2


meshctl cluster register enterprise \
  --mgmt-context=$MGMT_CONTEXT \
  --remote-context=$CLUSTER3 \
  --relay-server-address $ENTERPRISE_NETWORKING_ADDRESS \
  remotecluster3


helm install enterprise-agent enterprise-agent/enterprise-agent \
  --namespace gloo-mesh \
  --set relay.serverAddress=${SVC}:9900 \
  --set relay.cluster=gm-cluster-1 \
  --kube-context=${CLUSTER1} \
  --version 1.1.0-beta16

kubectl apply --context ${MGMT} -f- <<EOF
apiVersion: multicluster.solo.io/v1alpha1
kind: KubernetesCluster
metadata:
  name: gm-cluster-1
  namespace: gloo-mesh
spec:
  clusterDomain: cluster.local
EOF