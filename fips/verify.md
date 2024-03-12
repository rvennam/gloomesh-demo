Google forked OpenSSL and created BoringSSL

Istio uses BoringSSL

BoringCrypto is a library that provides FIPS 140–2 approved cryptographic algorithms to serve BoringSSL

Upstream golang/go repository maintains a separate dev branch dev.boringcrypto.go<go-version>.
https://github.com/golang/go/branches/all?query=dev.boringcrypto
This branch holds all the patches to make Go using BoringCrypto For the control plane, which requires a version of Go that uses the BoringCrypto module, we leverage go-fips which assembles the correct builds of Go with BoringCrypto

For data plane, envoy must be compiled with a FIPS validated cryptographic module



https://console.cloud.google.com/gcr/images/istio-enterprise/global/pilot

kubectl get iop example-istiocontrolplane -n istio-system -o yaml

kubectl exec -it -n istio-system deploy/istio-ingressgateway -- /usr/local/bin/envoy --version

kubectl cp istio-system/$(kubectl get pods -n istio-system -l app=istiod --output=jsonpath={.items..metadata.name}):/usr/local/bin/pilot-discovery pilot-discovery

chmod +x pilot-discovery

docker build . -t test

docker run -it test go version /tmp/pilot-discovery

/tmp/pilot-discovery: go1.16.4b7

https://go.googlesource.com/go/+/refs/heads/dev.boringcrypto.go1.12/misc/boring/

# Overview
- We use Google’s BoringCrypto module as the foundation of the security-1 FIPS compliant builds of Istio.
- BoringCrypto is a core module for the BoringSSL libraries that has been tested by CMVP to be FIPS validated.

- For the control plane, which requires a version of Go that uses the BoringCrypto module, we leverage go-fips which assembles the correct builds of Go with BoringCrypto.
  - https://github.com/golang/go/tree/dev.boringcrypto.go1.16/misc/boring
- FIPS 140-2 will reject RSA 4096-bit keys and certificates.



----

# Solo.io Istio FIPS Verification

## Download Istio 1.11.5 CLI:
```
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.11.5 sh -
```

## Install Solo Istio 1.11.5 FIPS:
```
cd ~/istio-1.11.5/bin
istioctl install --set hub=$REPO --set tag=1.12.6-fips
```

## Verify Istio Ingress Gateway is using FIPS
```
kubectl exec -it -n istio-system deploy/istio-ingressgateway -- /usr/local/bin/envoy --version
```
Look for "BoringSSL-FIPS" at the end

## Deploy a sample app with Istio sidecar
```
kubectl label namespace default istio-injection=enabled
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml
```

## Verify that sidecar is using FIPS
```
kubectl exec -it deploy/sleep -c istio-proxy -- /usr/local/bin/envoy --version
```
Look for "BoringSSL-FIPS" at the end
