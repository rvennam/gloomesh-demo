# Check cluster node locations
kubectl describe nodes | grep region
https://console.cloud.google.com/kubernetes/list?project=solo-test-236622

## DynamoDB Endpoints
https://docs.aws.amazon.com/general/latest/gr/ddb.html

## Debug container
kubectl apply -f https://github.com/rvennam/istio-on-iks/blob/master/sample_yamls/debug.yaml
kubectl exec --stdin --tty  deploy/debug -c debug -- /bin/sh

## Create SE
kubectl apply -f ./1-se.yaml

## Create DR
kubectl apply -f ./2-dr.yaml

# TEST
for i in {1..5}; do kubectl exec deploy/debug -c debug -- curl -sS http://mydb.com; echo; sleep 2; done