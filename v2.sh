# Workspaces bookinfo
# WorkspaceSettings bookinfo-settings in REMOTE_CONTEXT1

# Workspaces istio-system
# WorkspaceSettings istio-system-settings in REMOTE_CONTEXT1

kubectl delete RouteTable --context $MGMT_CONTEXT -n bookinfo --all
kubectl delete VirtualGateway --context $REMOTE_CONTEXT1 -n istio-system

kubectl apply --context $MGMT_CONTEXT -f- <<EOF
apiVersion: admin.gloo.solo.io/v2
kind: Workspace
metadata:
  name: bookinfo
  namespace: gloo-mesh
spec:
  workloadClusters:
  - name: '*'
    namespaces:
    - name: 'bookinfo'
EOF



kubectl apply --context $MGMT_CONTEXT -f- <<EOF
apiVersion: admin.gloo.solo.io/v2
kind: WorkspaceSettings
metadata:
  name: bookinfo-settings
  namespace: bookinfo
spec:
  exportTo:
  - workspaces:
    - name: istio-system
  options:
    serviceIsolation:
      enabled: true
    federation:
      enabled: true
      serviceSelector:
        - {}
      hostSuffix: 'global'
EOF

# Expose

kubectl apply --context $REMOTE_CONTEXT1 -f- <<EOF
apiVersion: networking.gloo.solo.io/v2
kind: VirtualGateway
metadata:
  name: north-south-gw
  namespace: istio-system
spec:
  workloads:
    - selector:
        labels:
          istio: ingressgateway
        cluster: ${REMOTE_CLUSTER1}
  listeners:
    - port:
        number: 80
      http: {}
EOF

kubectl apply --context $MGMT_CONTEXT -n bookinfo -f- <<EOF
apiVersion: networking.gloo.solo.io/v2
kind: RouteTable
metadata:
  name: bookinfo-routes
  namespace: bookinfo
  labels:
    workspace.solo.io/exported: 'true'
spec:
  hosts:
    - '*'
  # Selects the virtual gateway you previously created
  virtualGateways:
    - name: north-south-gw
      namespace: istio-system
      cluster: ${REMOTE_CLUSTER1}
  http:
    # Route for the main productpage app
    - name: productpage
      matchers:
      - uri:
          prefix: /productpage
      - uri:
          prefix: /static
      forwardTo:
        destinations:
          - ref:
              name: productpage
              namespace: bookinfo
              cluster: ${REMOTE_CLUSTER1}
            port:
              number: 9080
    # Routes all /reviews requests to the reviews-v1 or reviews-v2 apps in cluster-1
    - name: reviews
      labels:
        route: reviews
      matchers:
      - uri:
          prefix: /reviews
      forwardTo:
        destinations:
          - ref:
              name: reviews
              namespace: bookinfo
              cluster: ${REMOTE_CLUSTER1}
            port:
              number: 9080
EOF

