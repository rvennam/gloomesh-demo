kubectl config use-context mgmt
k delete workspaces -A -l app=scale-test

kubectl config use-context cluster1
kubectl delete all -l app=tcp-echo -A

kubectl config use-context cluster2
kubectl delete all -l app=tcp-echo -A
# for i in {1..1000}
# do
#   echo "Number: $i"
#   # kubectl delete all --all -n ns$i --wait=false
#   kubectl scale deploy tcp-echo --replicas=0 -n ns$i
# done
# kubectl config use-context cluster2
# for i in {1..1000}
# do
#   echo "Number: $i"
#   # kubectl delete all --all -n ns$i --wait=false
#   kubectl scale deploy tcp-echo --replicas=0 -n ns$i
# done

