kubectl config use-context cluster1

for i in {0..3000}
do
  echo "Number: $i"
  kubectl create ns ns$i
  # kubectl label ns ns$i istio-injection-
  kubectl label ns ns$i istio-injection=enabled
  kubectl config set-context --current --namespace=ns$i
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/tcp-echo/tcp-echo.yaml
  # kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.12/samples/bookinfo/platform/kube/bookinfo.yaml
  kubectl rollout restart deploy
  # kubectl apply -f https://raw.githubusercontent.com/rvennam/request-loop/main/kubernetes/deployment.yaml
  # kubectl scale deploy/request-loop --replicas=20
  # kubectl scale deploy/productpage-v1 --replicas=1
  # kubectl scale deploy/details-v1 --replicas=1
  # for x in {0..5}
  # do
  #   echo "Number: $x"
  #   export x=$x
  #   envsubst < fake-services.yaml > fake-services-values.yaml
  #   kubectl apply -f fake-services-values.yaml
  # done
  # kubectl scale deploy/ratings-v1 --replicas=1

  # kubectl apply -f ./VirtualService.yaml
done

# # for i in {1..2000}; do curl -I 10.84.34.166/productpage; sleep .1; done
# # gcloud container clusters resize rvennam-remote3 --node-pool pool-1 --num-nodes 1 --zone us-west1-c --async -q