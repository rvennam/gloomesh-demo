
gcloud container clusters get-credentials rvennam-mgmt --zone us-central1-c --project solo-test-236622
k config rename-context gke_solo-test-236622_us-central1-c_rvennam-mgmt mgmt

gcloud container clusters get-credentials rvennam-gm2-remote1 --zone us-east1-b --project solo-test-236622
k config rename-context gke_solo-test-236622_us-east1-b_rvennam-remote1 cluster1

gcloud container clusters get-credentials rvennam-gm2-remote2 --zone us-west1-c --project solo-test-236622
k config rename-context gke_solo-test-236622_us-west1-c_rvennam-remote3 cluster2

export MGMT_CLUSTER=mgmt
export REMOTE_CLUSTER1=cluster1
export REMOTE_CLUSTER2=cluster2

export MGMT_CONTEXT=gke_us-central1-c_rvennam-mgmt
export REMOTE_CONTEXT1=remotecluster1
export REMOTE_CONTEXT2=remotecluster2

export ISTIO_IMAGE_REPO=us-docker.pkg.dev/gloo-mesh/istio-workshops
export ISTIO_IMAGE_TAG=1.13.5-solo
export ISTIO_VERSION=1.13.5
export GLOO_MESH_VERSION=v2.0.8

curl -sL https://run.solo.io/meshctl/install | GLOO_MESH_VERSION=$GLOO_MESH_VERSION sh -


k config use-context $MGMT_CONTEXT

meshctl install \
  --kubecontext $MGMT_CONTEXT \
  --license $GLOO_MESH_LICENSE_KEY \
  --version $GLOO_MESH_VERSION \
  --set mgmtClusterName=$MGMT_CLUSTER

MGMT_SERVER_NETWORKING_DOMAIN=$(kubectl get svc -n gloo-mesh gloo-mesh-mgmt-server --context $MGMT_CONTEXT -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
MGMT_SERVER_NETWORKING_PORT=$(kubectl -n gloo-mesh get service gloo-mesh-mgmt-server --context $MGMT_CONTEXT -o jsonpath='{.spec.ports[?(@.name=="grpc")].port}')
MGMT_SERVER_NETWORKING_ADDRESS=${MGMT_SERVER_NETWORKING_DOMAIN}:${MGMT_SERVER_NETWORKING_PORT}
echo $MGMT_SERVER_NETWORKING_ADDRESS

k get secret -n gloo-mesh relay-root-tls-secret -o json | jq -r '.data["ca.crt"]' | base64 -d  > ca.crt
grpcurl -authority gloo-mesh-mgmt-server.gloo-mesh  -cacert=ca.crt $MGMT_SERVER_NETWORKING_ADDRESS list

# meshctl cluster register \
#   --kubecontext=$MGMT_CONTEXT \
#   --remote-context=$MGMT_CONTEXT \
#   --relay-server-address $MGMT_SERVER_NETWORKING_ADDRESS \
#   --version $GLOO_MESH_VERSION \
#   $MGMT_CLUSTER

meshctl cluster register \
  --kubecontext=$MGMT_CONTEXT \
  --remote-context=$REMOTE_CONTEXT1 \
  --relay-server-address $MGMT_SERVER_NETWORKING_ADDRESS \
  --version $GLOO_MESH_VERSION \
  $REMOTE_CLUSTER1

meshctl cluster register \
  --kubecontext=$MGMT_CONTEXT \
  --remote-context=$REMOTE_CONTEXT2 \
  --relay-server-address $MGMT_SERVER_NETWORKING_ADDRESS \
  --version $GLOO_MESH_VERSION \
  $REMOTE_CLUSTER2

kubectl create ns istio-gateways --context $REMOTE_CONTEXT1
kubectl create ns istio-gateways --context $REMOTE_CONTEXT2

CLUSTER_NAME=$REMOTE_CLUSTER1
cat << EOF | istioctl install -y --context $REMOTE_CONTEXT1 -f -
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: gloo-mesh-istio
  namespace: istio-system
spec:
  # only the control plane components are installed (https://istio.io/latest/docs/setup/additional-setup/config-profiles/)
  profile: minimal
  # Solo.io Istio distribution repository
  hub: $ISTIO_IMAGE_REPO
  # Solo.io Gloo Mesh Istio tag
  tag: ${ISTIO_VERSION}

  meshConfig:
    # enable access logging to standard output
    accessLogFile: /dev/stdout
    h2UpgradePolicy: UPGRADE

    defaultConfig:
      # wait for the istio-proxy to start before application pods
      holdApplicationUntilProxyStarts: true
      # enable Gloo Mesh metrics service (required for Gloo Mesh UI)
      envoyMetricsService:
        address: gloo-mesh-agent.gloo-mesh:9977
       # enable GlooMesh accesslog service (required for Gloo Mesh Access Logging)
      envoyAccessLogService:
        address: gloo-mesh-agent.gloo-mesh:9977
      proxyMetadata:
        # Enable Istio agent to handle DNS requests for known hosts
        # Unknown hosts will automatically be resolved using upstream dns servers in resolv.conf
        # (for proxy-dns)
        ISTIO_META_DNS_CAPTURE: "true"
        # Enable automatic address allocation (for proxy-dns)
        ISTIO_META_DNS_AUTO_ALLOCATE: "true"
        # Used for gloo mesh metrics aggregation
        # should match trustDomain (required for Gloo Mesh UI)
        GLOO_MESH_CLUSTER_NAME: ${CLUSTER_NAME}

    # The trust domain corresponds to the trust root of a system.
    # For Gloo Mesh this should be the name of the cluster that cooresponds with the CA certificate CommonName identity
    trustDomain: ${CLUSTER_NAME}
  components:
    ingressGateways:
    # enable the default ingress gateway
    - name: istio-ingressgateway
      namespace: istio-gateways
      enabled: true
      k8s:
        service:
          type: LoadBalancer
          ports:
            # main http ingress port
            - port: 80
              targetPort: 8080
              name: http2
            # main https ingress port
            - port: 443
              targetPort: 8443
              name: https
            - port: 5672
              targetPort: 5672
              name: amqp
    - name: istio-eastwestgateway
      enabled: true
      namespace: istio-gateways
      label:
        istio: eastwestgateway
      k8s:
        env:
          # Required by Gloo Mesh for east/west routing
          - name: ISTIO_META_ROUTER_MODE
            value: "sni-dnat"
        service:
          type: LoadBalancer
          selector:
            istio: eastwestgateway
          # Default ports
          ports:
            # Port for multicluster mTLS passthrough; required for Gloo Mesh east/west routing
            - port: 15443
              targetPort: 15443
              # Gloo Mesh looks for this default name 'tls' on a gateway
              name: tls
    pilot:
      k8s:
        env:
         # Allow multiple trust domains (Required for Gloo Mesh east/west routing)
          - name: PILOT_SKIP_VALIDATE_TRUST_DOMAIN
            value: "true"
          - name: PILOT_ENABLE_K8S_SELECT_WORKLOAD_ENTRIES
            value: "false"
          - name: PILOT_ENABLE_K8S_SELECT_WORKLOAD_ENTRIES
            value: "false"
  values:
    gateways:
      istio-ingressgateway:
        # Enable gateway injection
        injectionTemplate: gateway
    # https://istio.io/v1.5/docs/reference/config/installation-options/#global-options
    global:
      # needed for connecting VirtualMachines to the mesh
      network: ${CLUSTER_NAME}
      # needed for annotating istio metrics with cluster (should match trust domain and GLOO_MESH_CLUSTER_NAME)
      multiCluster:
        clusterName: ${CLUSTER_NAME}
EOF


CLUSTER_NAME=$REMOTE_CLUSTER2
cat << EOF | istioctl install -y --context $REMOTE_CONTEXT2 -f -
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: gloo-mesh-istio
  namespace: istio-system
spec:
  # only the control plane components are installed (https://istio.io/latest/docs/setup/additional-setup/config-profiles/)
  profile: minimal
  # Solo.io Istio distribution repository
  hub: $REPO
  # Solo.io Gloo Mesh Istio tag
  tag: ${ISTIO_VERSION}

  meshConfig:
    # enable access logging to standard output
    accessLogFile: /dev/stdout
    h2UpgradePolicy: UPGRADE

    defaultConfig:
      # wait for the istio-proxy to start before application pods
      holdApplicationUntilProxyStarts: true
      # enable Gloo Mesh metrics service (required for Gloo Mesh UI)
      envoyMetricsService:
        address: gloo-mesh-agent.gloo-mesh:9977
       # enable GlooMesh accesslog service (required for Gloo Mesh Access Logging)
      envoyAccessLogService:
        address: gloo-mesh-agent.gloo-mesh:9977
      proxyMetadata:
        # Enable Istio agent to handle DNS requests for known hosts
        # Unknown hosts will automatically be resolved using upstream dns servers in resolv.conf
        # (for proxy-dns)
        ISTIO_META_DNS_CAPTURE: "true"
        # Enable automatic address allocation (for proxy-dns)
        ISTIO_META_DNS_AUTO_ALLOCATE: "true"
        # Used for gloo mesh metrics aggregation
        # should match trustDomain (required for Gloo Mesh UI)
        GLOO_MESH_CLUSTER_NAME: ${CLUSTER_NAME}

    # The trust domain corresponds to the trust root of a system.
    # For Gloo Mesh this should be the name of the cluster that cooresponds with the CA certificate CommonName identity
    trustDomain: ${CLUSTER_NAME}
  components:
    ingressGateways:
    # enable the default ingress gateway
    - name: istio-ingressgateway
      namespace: istio-gateways
      enabled: true
      k8s:
        service:
          type: LoadBalancer
          ports:
            # main http ingress port
            - port: 80
              targetPort: 8080
              name: http2
            # main https ingress port
            - port: 443
              targetPort: 8443
              name: https
    - name: istio-eastwestgateway
      enabled: true
      namespace: istio-gateways
      label:
        istio: eastwestgateway
      k8s:
        env:
          # Required by Gloo Mesh for east/west routing
          - name: ISTIO_META_ROUTER_MODE
            value: "sni-dnat"
        service:
          type: LoadBalancer
          selector:
            istio: eastwestgateway
          # Default ports
          ports:
            # Port for multicluster mTLS passthrough; required for Gloo Mesh east/west routing
            - port: 15443
              targetPort: 15443
              # Gloo Mesh looks for this default name 'tls' on a gateway
              name: tls
    pilot:
      k8s:
        env:
         # Allow multiple trust domains (Required for Gloo Mesh east/west routing)
          - name: PILOT_SKIP_VALIDATE_TRUST_DOMAIN
            value: "true"
  values:
    gateways:
      istio-ingressgateway:
        # Enable gateway injection
        injectionTemplate: gateway
    # https://istio.io/v1.5/docs/reference/config/installation-options/#global-options
    global:
      # needed for connecting VirtualMachines to the mesh
      network: ${CLUSTER_NAME}
      # needed for annotating istio metrics with cluster (should match trust domain and GLOO_MESH_CLUSTER_NAME)
      multiCluster:
        clusterName: ${CLUSTER_NAME}
EOF

cat << EOF | kubectl --context $MGMT_CONTEXT apply -f -
apiVersion: admin.gloo.solo.io/v2
kind: RootTrustPolicy
metadata:
  name: root-trust-policy
  namespace: gloo-mesh
spec:
  config:
    mgmtServerCa:
      generated: {}
    autoRestartPods: true
EOF


kubectl apply -n web-ui -f https://raw.githubusercontent.com/solo-io/workshops/gloo-mesh-demo/gloo-mesh-demo/data/online-boutique/web-ui.yaml --context $REMOTE_CONTEXT1
kubectl apply -n backend-apis -f https://raw.githubusercontent.com/solo-io/workshops/gloo-mesh-demo/gloo-mesh-demo/data/online-boutique/backend-apis-cluster1.yaml --context $REMOTE_CONTEXT1
kubectl apply -n backend-apis -f https://raw.githubusercontent.com/solo-io/workshops/gloo-mesh-demo/gloo-mesh-demo/data/online-boutique/backend-apis-cluster1.yaml --context $REMOTE_CONTEXT2


kubectl apply -n backend-apis -f ./v2/checkout.yaml --context $REMOTE_CONTEXT1
kubectl apply -n web-ui -f https://raw.githubusercontent.com/solo-io/workshops/gloo-mesh-demo/gloo-mesh-demo/data/online-boutique/web-ui-with-checkout.yaml --context $REMOTE_CONTEXT1


kubectl create namespace ops --context $MGMT_CONTEXT
kubectl create namespace web --context $MGMT_CONTEXT
kubectl create namespace backend-apis --context $MGMT_CONTEXT


#!/bin/bash

kubectl --context ${CLUSTER1} create namespace gloo-mesh-addons
kubectl --context ${CLUSTER1} label namespace gloo-mesh-addons istio-injection=enabled

helm repo add gloo-mesh-agent https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-agent
helm repo update

helm upgrade --install gloo-mesh-agent-addons gloo-mesh-agent/gloo-mesh-agent \
  --namespace gloo-mesh-addons \
  --kube-context=${CLUSTER1} \
  --set glooMeshAgent.enabled=false \
  --set rate-limiter.enabled=true \
  --set ext-auth-service.enabled=true \
  --version $GLOO_MESH_VERSION

kubectl --context ${REMOTE_CONTEXT1} apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: oauth
  namespace: gloo-mesh
type: extauth.solo.io/oauth
data:
  client-secret: $(echo -n 8Y9c11kPS3x2yGsdDbT3YrfYgIit7KhJ9iBcnoO8zNORyLS4x0cE98jKR1To-f-I | base64)
EOF

kubectl apply -f https://raw.githubusercontent.com/solo-io/solo-cop/main/workshops/gloo-mesh-demo/tracks/06-api-gateway/gloo-mesh-addons-servers.yaml --context ${MGMT}