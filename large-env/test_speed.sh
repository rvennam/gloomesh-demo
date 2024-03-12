kubectl
counter=0
until [ "kubectl get vs -A --context cluster1 | wc -l" = 0 ]
do
  echo Counter: $counter
  sleep 1;
  ((counter++))
done