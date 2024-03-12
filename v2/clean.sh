# Fix patch
kubectl --context $REMOTE_CONTEXT1 -n backend-apis patch deploy checkoutservice --patch '{"spec":{"template":{"spec":{"containers":[{"name":"server","command":[],"readinessProbe":null,"livenessProbe":null}]}}}}'

kubectl delete -f ./11-rate-limit.yaml  --context $MGMT_CONTEXT

# Clean up Policies
kubectl delete -f ./09-failover-outlier.yaml  --context $MGMT_CONTEXT

# Reset Apps
kubectl apply -f ./00-web-ui.yaml --context $REMOTE_CONTEXT1

# Clean up checkout from cluster2
# kubectl delete -f ./05-checkout-feature-cluster2.yaml  --context $REMOTE_CONTEXT2

# Clean up frontend from cluster2
# kubectl delete -f ./07-web-ui-cluster2.yaml  --context $REMOTE_CONTEXT2

# Clean up VirtualGateway & RouteTable
kubectl delete routetables.networking.gloo.solo.io frontend -n web-team --context $MGMT_CONTEXT
kubectl delete virtualgateway north-south-gw -n ops-team --context $MGMT_CONTEXT

# Clean up RootTrust
# kubectl delete roottrustpolicy root-trust-policy -n gloo-mesh --context $MGMT_CONTEXT

# Clean up Access Policies
kubectl delete AccessPolicy --all -A --context $MGMT_CONTEXT

kubectl delete OutlierDetectionPolicy,FailoverPolicy,ExtAuthPolicy,VirtualDestination,AccessPolicy,RateLimitPolicy,FaultInjectionPolicy -A --all  --context $MGMT_CONTEXT

# Clean up Workspaces
kubectl delete -f ./01-workspace.yaml --context $MGMT_CONTEXT
# ---