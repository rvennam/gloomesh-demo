
kubectl delete secret  relay-client-tls-secret -n gloo-mesh --context ${CLUSTER1}
kubectl delete secret  relay-client-tls-secret -n gloo-mesh --context ${CLUSTER2}

kubectl get secret relay-root-tls-secret -n gloo-mesh --context ${MGMT} -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
kubectl delete secret  relay-root-tls-secret -n gloo-mesh --context ${CLUSTER1}
kubectl delete secret  relay-root-tls-secret -n gloo-mesh --context ${CLUSTER2}
kubectl create secret generic relay-root-tls-secret -n gloo-mesh --context ${CLUSTER1} --from-file ca.crt=ca.crt
kubectl create secret generic relay-root-tls-secret -n gloo-mesh --context ${CLUSTER2} --from-file ca.crt=ca.crt
rm ca.crt

kubectl get secret relay-identity-token-secret -n gloo-mesh --context ${MGMT} -o jsonpath='{.data.token}' | base64 -d > token
kubectl delete secret   relay-identity-token-secret -n gloo-mesh --context ${CLUSTER1}
kubectl delete secret   relay-identity-token-secret -n gloo-mesh --context ${CLUSTER2}
kubectl create secret generic relay-identity-token-secret -n gloo-mesh --context ${CLUSTER1} --from-file token=token
kubectl create secret generic relay-identity-token-secret -n gloo-mesh --context ${CLUSTER2} --from-file token=token
rm token