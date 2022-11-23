rm -rf ./gloo-mesh-agent
rm -rf ./gloo-mesh-enterprise

export UPGRADE_VERSION=2.0.15
export MGMT_CONTEXT=mgmt
export REMOTE_CONTEXT1=cluster1
export REMOTE_CONTEXT2=cluster2
export NAMESPACE=gloo-mesh

helm repo update --kube-context $MGMT_CONTEXT
helm pull gloo-mesh-enterprise/gloo-mesh-enterprise --kube-context $MGMT_CONTEXT --version $UPGRADE_VERSION --untar
kubectl apply --context $MGMT_CONTEXT -f gloo-mesh-enterprise/charts/gloo-mesh-crds/crds/


helm repo update --kube-context $REMOTE_CONTEXT1
helm pull gloo-mesh-agent/gloo-mesh-agent --version $UPGRADE_VERSION --kube-context $REMOTE_CONTEXT1 --untar

kubectl apply --context $REMOTE_CONTEXT1 -f gloo-mesh-agent/charts/gloo-mesh-crds/crds
kubectl apply --context $REMOTE_CONTEXT1 -f gloo-mesh-agent/charts/ext-auth-service/crds
kubectl apply --context $REMOTE_CONTEXT1 -f gloo-mesh-agent/charts/rate-limiter/crds

kubectl apply --context $REMOTE_CONTEXT2 -f gloo-mesh-agent/charts/gloo-mesh-crds/crds
kubectl apply --context $REMOTE_CONTEXT2 -f gloo-mesh-agent/charts/ext-auth-service/crds
kubectl apply --context $REMOTE_CONTEXT2 -f gloo-mesh-agent/charts/rate-limiter/crds

helm upgrade gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise \
--namespace gloo-mesh \
--set licenseKey=${GLOO_MESH_LICENSE_KEY} \
--kube-context=${MGMT_CONTEXT} \
--version ${UPGRADE_VERSION} \
--set mgmtClusterName=$MGMT_CLUSTER

helm upgrade gloo-mesh-agent gloo-mesh-agent/gloo-mesh-agent \
--kube-context=${REMOTE_CONTEXT1} \
--namespace gloo-mesh \
--version ${UPGRADE_VERSION}

helm upgrade gloo-mesh-agent gloo-mesh-agent/gloo-mesh-agent \
--kube-context=${REMOTE_CONTEXT2} \
--namespace gloo-mesh \
--version ${UPGRADE_VERSION}

