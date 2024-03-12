for i in {0..100}
do
  kubectl apply -f .
  sleep 3
  kubectl delete -f .
  sleep 3
done