# Clean up
kubectl patch deployment reviews-v1  --type json   -p '[{"op": "remove", "path": "/spec/template/spec/containers/0/command"}]'
kubectl delete deploy reviews-v2 --context $CLUSTER1

k delete -n gloo-mesh TrafficPolicy reviews-tp
k delete  -n gloo-mesh TrafficPolicy simple
k delete  -n gloo-mesh TrafficPolicy reviews-vd
k delete  -n gloo-mesh accesspolicy bookinfo
k delete  -n gloo-mesh accesspolicy istio-ingressgateway
k delete  -n gloo-mesh VirtualMesh virtual-mesh
k delete  -n gloo-mesh AccessLogRecord --all