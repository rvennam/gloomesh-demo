kubectl delete AuthorizationPolicy --all
kubectl delete VirtualService reviews
kubectl label ns default istio-injection-
kubectl delete pods --all