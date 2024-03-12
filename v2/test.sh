export INGRESS_HOST=$(kubectl -n istio-gateways get service istio-ingressgateway  --context $REMOTE_CONTEXT1 -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

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
    sleep 5
    kubectl get -f ./03-virtualgateway.yaml --context $MGMT_CONTEXT -o yaml
    kubectl get -f ./04-routetable.yaml --context $MGMT_CONTEXT -o yaml
    curl $INGRESS_HOST
    echo "http://"$INGRESS_HOST
}

# Deploy checkout to cluster 2 & Apply VD
function deployCheckoutToCluster2(){
    kubectl apply -f ./06-virtualdestinations.yaml --context $MGMT_CONTEXT
    kubectl apply -f ./05-checkout-feature-cluster2.yaml --context $REMOTE_CONTEXT2
    sleep 40
    curl $INGRESS_HOST/cart | grep empty

}

# Deploy frontend to cluster2 & update Routetable to point to VD
function deployFrontendToCluster2(){
    kubectl apply -f ./07-web-ui-cluster2.yaml --context $REMOTE_CONTEXT2
    kubectl apply -f ./08-routetable-vd-frontend.yaml  --context $MGMT_CONTEXT
    sleep 5
    for i in {1..3}; do curl -s $INGRESS_HOST | grep "Cluster Name"; done
    kubectl delete pods -l app=frontend -n web-ui  --context $REMOTE_CONTEXT1
    for i in {1..3}; do curl -s $INGRESS_HOST | grep "Cluster Name"; done
    echo "waiting for cluster1 frontend pod to come back up"
    sleep 15
    for i in {1..3}; do curl -s $INGRESS_HOST | grep "Cluster Name"; done
}

# apply Locality LB to frontend
function applyLocalityLB(){
    kubectl apply -f ./09-failover-outlier.yaml  --context $MGMT_CONTEXT
    sleep 15
    for i in {1..20}; do curl -s $INGRESS_HOST | grep "Cluster Name"; done
}

function testAccessPolicies(){
    kubectl apply -f ./secure/allow-nothing.yaml  --context $MGMT_CONTEXT
    sleep 6
    curl -s $INGRESS_HOST | grep "RBAC"
    sleep 2
    kubectl apply -f ./secure/access-policies.yaml  --context $MGMT_CONTEXT
    sleep 10
    curl -s $INGRESS_HOST | grep "Sunglasses"
}

function applyExtAuth(){
    kubectl apply -f ./10-secure-gateway.yaml --context $MGMT_CONTEXT
    export ENDPOINT_HTTPS_GW_CLUSTER1_EXT=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):443
    echo "Secure Online Boutique URL: https://$ENDPOINT_HTTPS_GW_CLUSTER1_EXT"

    # export KEYCLOAK_URL=$(kubectl get configmap -n gloo-mesh --context $CLUSTER1 keycloak-info -o json | jq -r '.data."keycloak-url"')
    # export KEYCLOAK_CLIENTID=$(kubectl get configmap -n gloo-mesh --context $CLUSTER1 keycloak-info -o json | jq -r '.data."client-id"')

    # echo "Keycloak available at: $KEYCLOAK_URL"
    # echo "Keycloak OIDC ClientID: $KEYCLOAK_CLIENTID"
    # ( echo "cat <<EOF" ; cat ext-auth-policy-template.yaml ; echo EOF ) | sh | kubectl apply -n web-team --context $MGMT -f -
    kubectl apply -f ./11-ext-auth.yaml  --context $MGMT_CONTEXT
    echo "Secure Online Boutique URL: https://$ENDPOINT_HTTPS_GW_CLUSTER1_EXT"
}

##########




read -n 1 -p  "Deploy apps to cluster1? [y,n]" doit
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


# read -n1 -p "Apply Locality LB to frontend? [y,n]" doit
# case $doit in
#   y|Y) applyLocalityLB ;;
# esac


read -n1 -p "Test Access Policies? [y,n]" doit
case $doit in
  y|Y) testAccessPolicies ;;
esac

read -n1 -p "Apply ExtAuth? [y,n]" doit
case $doit in
  y|Y) applyExtAuth ;;
esac



# BREAK:
# kubectl --context $REMOTE_CONTEXT1 -n backend-apis patch deploy checkoutservice --patch '{"spec":{"template":{"spec":{"containers":[{"name":"server","command":["sleep","20h"],"readinessProbe":null,"livenessProbe":null}]}}}}'
# UNDO:
# kubectl --context $REMOTE_CONTEXT1 -n backend-apis patch deploy checkoutservice --patch '{"spec":{"template":{"spec":{"containers":[{"name":"server","command":[],"readinessProbe":null,"livenessProbe":null}]}}}}'
