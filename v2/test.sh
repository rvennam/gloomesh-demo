
# Apply apps
function deployAppsToCluster1(){
    kubectl apply -f ./00-backend-apis.yaml   --context $REMOTE_CONTEXT1
    kubectl apply -f ./00-web-ui.yaml   --context $REMOTE_CONTEXT1
}

# Apply Workspaces & RootTrust
function createWorkspace(){
    kubectl apply -f ./01-workspace.yaml --context $MGMT_CONTEXT
    kubectl apply -f ./02-roottrustpolicy.yaml  --context $MGMT_CONTEXT
}

# Apply VirtualGateway & RouteTable
function applyVGandRT(){
    kubectl apply -f ./03-virtualgateway.yaml --context $MGMT_CONTEXT
    kubectl apply -f ./04-routetable.yaml --context $MGMT_CONTEXT
    sleep 5s
    export INGRESS_HOST=$(kubectl -n istio-gateways get service istio-ingressgateway  --context $REMOTE_CONTEXT1 -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    curl $INGRESS_HOST
    echo "http://"$(kubectl --context $REMOTE_CONTEXT1 -n istio-gateways get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
}

# Deploy checkout to cluster 2 & Apply VD
function deployCheckoutToCluster2(){
    kubectl apply -f ./05-checkout-feature-cluster2.yaml --context $REMOTE_CONTEXT2
    sleep 5s
    kubectl apply -f ./06-virtualdestinations.yaml --context $MGMT_CONTEXT
}

# Deploy frontend to cluster2 & update Routetable to point to VD
function deployFrontendToCluster2(){
    kubectl apply -f ./07-web-ui-cluster2.yaml --context $REMOTE_CONTEXT2
    kubectl apply -f ./08-routetable-vd-frontend.yaml  --context $MGMT_CONTEXT
    sleep 10
    for i in {1..10}; do curl -s $INGRESS_HOST | grep "Cluster Name"; done
}

# apply Locality LB to frontend
function applyLocalityLB(){
    kubectl apply -f ./09-failover-outlier.yaml  --context $MGMT_CONTEXT
    sleep 3
    for i in {1..10}; do curl -s $INGRESS_HOST | grep "Cluster Name"; done
}

##########




read -n 1 -p "Deploy apps to cluster1? [y,n]" doit
case $doit in
  y|Y) deployAppsToCluster1 ;;
esac

read -n1 -p "Apply Workspaces & RootTrust? [y,n]" doit
case $doit in
  y|Y) createWorkspace ;;
esac


read -n1 -p "Apply VirtualGateway & RouteTable [y,n]" doit
case $doit in
  y|Y) applyVGandRT ;;
esac

read -n1 -p "Deploy checkout to cluster2 and update VD? [y,n]" doit
case $doit in
  y|Y) deployCheckoutToCluster2 ;;
esac

read -n1 -p "Deploy frontend to cluster2 and update RT? [y,n]" doit
case $doit in
  y|Y) deployFrontendToCluster2 ;;
esac


read -n1 -p "Apply Locality LB to frontend? [y,n]" doit
case $doit in
  y|Y) applyLocalityLB ;;
esac




# BREAK:
# kubectl --context $REMOTE_CONTEXT1 -n backend-apis patch deploy checkoutservice --patch '{"spec":{"template":{"spec":{"containers":[{"name":"server","command":["sleep","20h"],"readinessProbe":null,"livenessProbe":null}]}}}}'
# UNDO:
# kubectl --context $REMOTE_CONTEXT1 -n backend-apis patch deploy checkoutservice --patch '{"spec":{"template":{"spec":{"containers":[{"name":"server","command":[],"readinessProbe":null,"livenessProbe":null}]}}}}'
