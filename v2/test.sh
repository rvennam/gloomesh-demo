# Fix patch
kubectl --context $REMOTE_CONTEXT1 -n backend-apis patch deploy checkoutservice --patch '{"spec":{"template":{"spec":{"containers":[{"name":"server","command":[],"readinessProbe":null,"livenessProbe":null}]}}}}'

# Clean up Policies
kubectl delete -f ./09-failover-outlier.yaml  --context $MGMT_CONTEXT

# Clean up VD
kubectl delete vd --all -n backend-apis-team --context $MGMT_CONTEXT
kubectl apply -f ./00-web-ui.yaml --context $REMOTE_CONTEXT1
sleep 20s

# Clean up checkout from cluster1 and 2
kubectl delete -f ./08-checkout-feature-cluster1.yaml  --context $REMOTE_CONTEXT1
kubectl delete -f ./05-checkout-feature-cluster2.yaml  --context $REMOTE_CONTEXT2

# Clean up VirtualGateway & RouteTable
kubectl delete routetables.networking.gloo.solo.io frontend -n web-team --context $MGMT_CONTEXT
kubectl delete virtualgateway north-south-gw -n ops-team --context $MGMT_CONTEXT

# Clean up RootTrust
kubectl delete roottrustpolicy root-trust-policy -n gloo-mesh --context $MGMT_CONTEXT

# Clean up Workspaces
kubectl delete -f ./01-workspace.yaml --context $MGMT_CONTEXT


# ---

# Apply apps
kubectl apply -f ./00-backend-apis-cluster1.yaml   --context $REMOTE_CONTEXT1
kubectl apply -f ./00-web-ui.yaml   --context $REMOTE_CONTEXT1

# Apply Workspaces
kubectl apply -f ./01-workspace.yaml --context $MGMT_CONTEXT

# Apply RootTrust
kubectl apply -f ./02-roottrustpolicy.yaml  --context $MGMT_CONTEXT

# Apply VirtualGateway & RouteTable
kubectl apply -f ./03-virtualgateway.yaml --context $MGMT_CONTEXT
kubectl apply -f ./04-routetable.yaml --context $MGMT_CONTEXT



# Apply VD
kubectl apply -f ./05-checkout-feature-cluster2.yaml --context $REMOTE_CONTEXT2
kubectl apply -f ./06-virtualdestinations.yaml --context $MGMT_CONTEXT
kubectl apply -f ./07-web-ui-with-checkout.yaml --context $REMOTE_CONTEXT1

# Apply Policies
kubectl apply -f ./08-checkout-feature-cluster1.yaml --context $REMOTE_CONTEXT1
kubectl apply -f ./09-failover-outlier.yaml  --context $MGMT_CONTEXT

# BREAK:
kubectl --context $REMOTE_CONTEXT1 -n backend-apis patch deploy checkoutservice --patch '{"spec":{"template":{"spec":{"containers":[{"name":"server","command":["sleep","20h"],"readinessProbe":null,"livenessProbe":null}]}}}}'
# UNDO:
kubectl --context $REMOTE_CONTEXT1 -n backend-apis patch deploy checkoutservice --patch '{"spec":{"template":{"spec":{"containers":[{"name":"server","command":[],"readinessProbe":null,"livenessProbe":null}]}}}}'
