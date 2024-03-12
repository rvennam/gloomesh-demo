kubectl config use-context mgmt
# for x in {0..1000}
# do
#   echo "Number: $x"
#   export x=$x
#   kubectl delete Workspace scale-test${x} -n gloo-mesh
#   kubectl delete ns ns${x}
# done
kubectl config use-context cluster1
for i in {1..1000}
do
  echo "Number: $i"
  # kubectl delete all --all -n ns$i --wait=false
  kubectl scale deploy tcp-echo --replicas=0 -n ns$i
done
kubectl config use-context cluster2
for i in {1..1000}
do
  echo "Number: $i"
  # kubectl delete all --all -n ns$i --wait=false
  kubectl scale deploy tcp-echo --replicas=0 -n ns$i
done

