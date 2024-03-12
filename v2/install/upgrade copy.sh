rm -rf ./gloo-mesh-agent
rm -rf ./gloo-mesh-enterprise

export UPGRADE_VERSION=2.4.4
export MGMT_CONTEXT=mgmt
export REMOTE_CONTEXT1=cluster1
export REMOTE_CONTEXT2=cluster2
export NAMESPACE=gloo-mesh

helm repo update --kube-context $MGMT_CONTEXT
helm pull gloo-mesh-enterprise/gloo-mesh-enterprise --kube-context $MGMT_CONTEXT --version $UPGRADE_VERSION --untar
kubectl apply --context $MGMT_CONTEXT -f gloo-mesh-enterprise/charts/gloo-mesh-crds/crds/

sleep 3

helm repo update --kube-context $REMOTE_CONTEXT1
helm pull gloo-mesh-agent/gloo-mesh-agent --version $UPGRADE_VERSION --kube-context $REMOTE_CONTEXT1 --untar

sleep 3

kubectl apply --context $REMOTE_CONTEXT1 -f gloo-mesh-agent/charts/gloo-mesh-crds/crds
kubectl apply --context $REMOTE_CONTEXT1 -f gloo-mesh-agent/charts/ext-auth-service/crds
kubectl apply --context $REMOTE_CONTEXT1 -f gloo-mesh-agent/charts/rate-limiter/crds

kubectl apply --context $REMOTE_CONTEXT2 -f gloo-mesh-agent/charts/gloo-mesh-crds/crds
kubectl apply --context $REMOTE_CONTEXT2 -f gloo-mesh-agent/charts/ext-auth-service/crds
kubectl apply --context $REMOTE_CONTEXT2 -f gloo-mesh-agent/charts/rate-limiter/crds

sleep 3

kubectl create ns gloo-mesh --context=${MGMT_CONTEXT}
helm upgrade --install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise \
--namespace gloo-mesh \
--set licenseKey=${GLOO_MESH_LICENSE_KEY} \
--kube-context=${MGMT_CONTEXT} \
--version ${UPGRADE_VERSION} \
--set mgmtClusterName=mgmt-cluster

sleep 3

export RELAY_IP=$(kubectl -n gloo-mesh get service gloo-mesh-mgmt-server --context ${MGMT_CONTEXT} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo $RELAY_IP

kubectl create ns gloo-mesh --context=${REMOTE_CONTEXT1}
helm upgrade --install gloo-platform gloo-platform/gloo-platform \
  --namespace=gloo-mesh \
  --kube-context=${CLUSTER1} \
  --version=2.3.18 \
 -f -<<EOF
common:
  cluster: cluster1
glooAgent:
  enabled: true
  relay:
    serverAddress: "${RELAY_IP}:9900"
    authority: gloo-mesh-mgmt-server.gloo-mesh
EOF



sleep 3
kubectl create ns gloo-mesh --context=${REMOTE_CONTEXT2}
helm upgrade --install gloo-mesh-agent gloo-mesh-agent/gloo-mesh-agent \
--kube-context=${REMOTE_CONTEXT2} \
--namespace gloo-mesh \
--version ${UPGRADE_VERSION} \
--set relay.serverAddress=${RELAY_IP}:9900

sleep 3
kubectl create ns gloo-mesh-addons --context=${REMOTE_CONTEXT1}
helm upgrade --install gloo-mesh-agent-addons gloo-mesh-agent/gloo-mesh-agent \
  --namespace gloo-mesh-addons \
  --kube-context=${REMOTE_CONTEXT1} \
  --set glooMeshAgent.enabled=false \
  --set rate-limiter.enabled=true \
  --set ext-auth-service.enabled=true \
  --version $UPGRADE_VERSION

sleep 3
kubectl create ns gloo-mesh-addons --context=${REMOTE_CONTEXT2}
helm upgrade --install gloo-mesh-agent-addons gloo-mesh-agent/gloo-mesh-agent \
  --namespace gloo-mesh-addons \
  --kube-context=${REMOTE_CONTEXT2} \
  --set glooMeshAgent.enabled=false \
  --set rate-limiter.enabled=true \
  --set ext-auth-service.enabled=true \
  --version $UPGRADE_VERSION

