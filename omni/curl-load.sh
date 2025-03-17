set -x
export CLUSTER1=gke_ambient_one
export GLOO_HTTP_IP=$(kubectl get svc -n gloo-system gloo-proxy-http --context $CLUSTER1 -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")
export GLOO_HTTPS_IP=$(kubectl get svc -n gloo-system gloo-proxy-https-httpbin --context $CLUSTER1 -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")
while true
do
  for ((i=1; i<=$((RANDOM % 10 + 1)); i++)); do curl --connect-timeout 1 -I -k http://${GLOO_HTTP_IP}/productpage; done
  for ((i=1; i<=$((RANDOM % 10 + 1)); i++)); do curl --connect-timeout 1 -I  -k https://${GLOO_HTTPS_IP}/headers; done
  for ((i=1; i<=$((RANDOM % 10 + 1)); i++)); do curl --connect-timeout 1 -I -k http://${GLOO_HTTP_IP}/productpage; done
  for ((i=1; i<=$((RANDOM % 10 + 1)); i++)); do curl --connect-timeout 1 -I -k http://${GLOO_HTTP_IP}/headers; done
  for ((i=1; i<=$((RANDOM % 5 + 1)); i++)); do curl --connect-timeout 1 -I -k https://${GLOO_HTTPS_IP}/status/500; done
  sleep $((RANDOM % 30 + 1))
done