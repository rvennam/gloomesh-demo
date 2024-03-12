# Clean up
kubectl patch deployment reviews-v1  --type json   -p '[{"op": "remove", "path": "/spec/template/spec/containers/0/command"}]'
kubectl patch deployment reviews-v2  --type json   -p '[{"op": "remove", "path": "/spec/template/spec/containers/0/command"}]'
kubectl patch deployment reviews-v3  --type json   -p '[{"op": "remove", "path": "/spec/template/spec/containers/0/command"}]'


k delete -n gloo-mesh AccessLogRecord --all
k delete -n gloo-mesh TrafficPolicy --all
k delete -n gloo-mesh accesspolicy --all
k delete -n gloo-mesh virtualhost --all
k delete -n gloo-mesh virtualgateway --all
k delete -n gloo-mesh VirtualDestination --all
k delete -n gloo-mesh RateLimitServerConfig --all
k delete -n gloo-mesh VirtualMesh --all


k delete -n gloo-mesh IstioInstallation --all
# cluster2
istioctl x uninstall --purge -y
k rollout restart deploy