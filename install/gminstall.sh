kubectl create ns gloo-mesh
helm install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise  -n gloo-mesh --version=1.1.0-beta16 --set licenseKey=${GLOO_MESH_LICENSE_KEY}  --set metricsBackend.prometheus.enabled=true   --set rbac-webhook.enabled=true

SVC=$(kubectl -n gloo-mesh get svc enterprise-networking -o jsonpath='{.status.loadBalancer.ingress[0].ip}') && echo $SVC

meshctl cluster register --mgmt-context=rvennam-mgmt --remote-context=rvennam-us-east-remote1 --relay-server-address=$SVC:9900 enterprise remotecluster1
meshctl cluster register --mgmt-context=rvennam-mgmt --remote-context=rvennam-us-west-remote2 --relay-server-address=$SVC:9900 enterprise remotecluster2

k edit rolebindings.rbac.enterprise.mesh.gloo.solo.io admin-role-binding -n gloo-mesh



##
helm template gloo-mesh-crds/gloo-mesh-crds --include-crds --version v1.1.0-beta23
elm template agent-crds/agent-crds --include-crds --version v1.1.0-beta23 | kubectl apply -f -