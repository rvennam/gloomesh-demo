
---
title: "Gloo Mesh Enterprise"
description: Reference for Helm values.
weight: 2
---

|Option|Type|Default Value|Description|
|------|----|-----------|-------------|
|insecure|bool|false|Set to true to enable insecure communication between Gloo Mesh components|
|devMode|bool|false|Set to true to enable dev mode for the logger.|
|verbose|bool|false|If true, enables verbose/debug logging.|
|leaderElection|bool|true|If true, leader election will be enabled|
|global|struct| |Values shared by Gloo Mesh Enterprise chart and its subcharts.|
|global.cluster|string|mgmt-cluster|In the special case where the management server is also running in a managed cluster with an agent, set this string to the name of the managed cluster.|
|adminNamespace|string| |The admin namespace to use for Gloo Mesh. The admin namespace will serve as the home for 'global' configuration, such as Workspaces and Kubernetes Clusters resources. The 'global overrides' WorkspaceSettings will also be read from this namespace, if it exists.|
|mgmtClusterName|string|mgmt-cluster|DEPRECATED: Use global.cluster, In the special case where the management server is also running in a managed cluster with an agent, set this string to the name of the managed cluster.|
|licenseKey|string| |Legacy Gloo Mesh Enterprise license key|
|glooGatewayLicenseKey|string| |Gloo Gateway license key|
|glooMeshLicenseKey|string| |Gloo Mesh Enterprise license key|
|glooNetworkLicenseKey|string| |Gloo Network license key|
|glooTrialLicenseKey|string| |Gloo trial license key|
|licenseSecretName|string| |this value is optional, but if used will take priority over any other licenseKeys and gloo mesh will look at the licenseSecretName in the namespace that gloo mesh is deployed in.|
|prometheusUrl|string|http://prometheus-server|Specify the URL of the Prometheus server.|
|prometheus|map[string, interface]|{"alertmanager":{"enabled":false},"enabled":true,"kubeStateMetrics":{"enabled":false},"nodeExporter":{"enabled":false},"podSecurityPolicy":{"enabled":false},"pushgateway":{"enabled":false},"rbac":{"create":true},"server":{"fullnameOverride":"prometheus-server","persistentVolume":{"enabled":false}},"serverFiles":{"alerting_rules.yml":{"groups":[{"name":"GlooPlatformAlerts","rules":[{"alert":"GlooPlatformTranslationLatencyIsHigh","annotations":{"runbook":"https://docs.solo.io/gloo-mesh-enterprise/main/troubleshooting/gloo/","summary":"The translation time has increased above 10 sec. It's currently {{ $value | humanize }}."},"expr":"histogram_quantile(0.99, sum(rate(gloo_mesh_translation_time_sec_bucket[5m])) by(le)) \u003e 10","for":"15m","labels":{"severity":"warning"}},{"alert":"GlooPlatformReconscilerLatencyIsHigh","annotations":{"runbook":"https://docs.solo.io/gloo-mesh-enterprise/main/troubleshooting/gloo/","summary":"The reconciliation time has increased above 80 sec. It's currently {{ $value | humanize }}."},"expr":"histogram_quantile(0.99, sum(rate(gloo_mesh_reconciler_time_sec_bucket[5m])) by(le)) \u003e 80","for":"15m","labels":{"severity":"warning"}},{"alert":"GlooPlatformAgentsAreDisconnected","annotations":{"runbook":"https://docs.solo.io/gloo-mesh-enterprise/main/troubleshooting/gloo/","summary":"The following cluster is disconnected: {{ $labels.cluster }}. Check the Gloo Platform Agent pod in the cluster!"},"expr":"count by(cluster) (sum by(cluster) (relay_push_clients_warmed == 0)) \u003e 0","for":"5m","labels":{"severity":"warning"}},{"alert":"GlooPlatformTranslationWarnings","annotations":{"runbook":"https://docs.solo.io/gloo-mesh-enterprise/main/troubleshooting/gloo/","summary":"Gloo Platform has detected {{$value | humanize}} translation warnings in the last 5m. Check your {{ $labels.gvk }} resources!"},"expr":"increase(translation_warning[5m]) \u003e 0","labels":{"severity":"warning"}},{"alert":"GlooPlatformTranslationErrors","annotations":{"runbook":"https://docs.solo.io/gloo-mesh-enterprise/main/troubleshooting/gloo/","summary":"Gloo Platform has detected {{$value | humanize}} translation errors in the last 5m. Check your {{ $labels.gvk }} resources!"},"expr":"increase(translation_error[5m]) \u003e 0","labels":{"severity":"warning"}},{"alert":"GlooPlatformRedisErrors","annotations":{"runbook":"https://docs.solo.io/gloo-mesh-enterprise/main/troubleshooting/gloo/","summary":"Gloo Platform has detected {{$value | humanize}} Redis sync errors in the last 5m."},"expr":"increase(gloo_mesh_redis_sync_err[5m]) \u003e 0","labels":{"severity":"warning"}}]}]},"prometheus.yml":{"scrape_configs":[{"job_name":"gloo-platform-pods","kubernetes_sd_configs":[{"namespaces":{"names":["gloo-mesh"]},"role":"pod"}],"relabel_configs":[{"action":"keep","regex":true,"source_labels":["__meta_kubernetes_pod_annotation_prometheus_io_scrape"]},{"action":"replace","regex":"(.+)","source_labels":["__meta_kubernetes_pod_annotation_prometheus_io_path"],"target_label":"__metrics_path__"},{"action":"replace","regex":"([^:]+)(?::\\d+)?;(\\d+)","replacement":"$1:$2","source_labels":["__address__","__meta_kubernetes_pod_annotation_prometheus_io_port"],"target_label":"__address__"},{"action":"labelmap","regex":"__meta_kubernetes_pod_label_(.+)"},{"action":"replace","source_labels":["__meta_kubernetes_namespace"],"target_label":"namespace"},{"action":"replace","source_labels":["__meta_kubernetes_pod_name"],"target_label":"pod"},{"action":"keep","regex":"gloo-mesh-mgmt-server","source_labels":["__meta_kubernetes_pod_label_app"]}],"scrape_interval":"15s","scrape_timeout":"10s"}]}},"serviceAccounts":{"alertmanager":{"create":false},"nodeExporter":{"create":false},"pushgateway":{"create":false},"server":{"create":true}}}|Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.<MAP_KEY>|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.alertmanager|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.enabled|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.kubeStateMetrics|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.nodeExporter|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.podSecurityPolicy|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.pushgateway|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.rbac|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.server|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.serverFiles|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|prometheus.serviceAccounts|interface| |Helm values for configuring Prometheus. See the [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) for the complete set of values.|
|registerMgmtPlane|struct| |Install the Gloo Mesh Agent bundled with the Mmgt Server to a single cluster. This is useful for registering the management cluster as a workload cluster in a single-cluster setup.|
|registerMgmtPlane.enabled|bool|false|enable installation of the agent when installing the management server|
|registerMgmtPlane.AgentValues|struct|{"insecure":false,"devMode":false,"verbose":false,"leaderElection":true,"cluster":"","relay":{"serverAddress":"gloo-mesh-mgmt-server:9900","authority":"gloo-mesh-mgmt-server.gloo-mesh","clientTlsSecret":{"name":"relay-client-tls-secret"},"rootTlsSecret":{"name":"relay-root-tls-secret"},"tokenSecret":{"name":"relay-identity-token-secret","namespace":"","key":"token"}},"maxGrpcMessageSize":"4294967295","metricsBufferSize":50,"accessLogsBufferSize":50,"istiodSidecar":{"createRoleBinding":false,"istiodServiceAccount":{"name":"istiod","namespace":"istio-system"}},"ext-auth-service":{"enabled":false,"extraTemplateAnnotations":{"proxy.istio.io/config":"{ \"holdApplicationUntilProxyStarts\": true }"}},"rate-limiter":{"enabled":false,"extraTemplateAnnotations":{"proxy.istio.io/config":"{ \"holdApplicationUntilProxyStarts\": true }"}},"sidecar-accel":{"enabled":false},"gloo-network-agent":{"enabled":false},"managedInstallations":{"images":{"hub":"us-docker.pkg.dev/gloo-mesh/istio-a9797008feb0","tag":"1.13.5"},"controlPlane":{"enabled":true,"overrides":{}},"northSouthGateways":[{"name":"istio-ingressgateway","enabled":true,"overrides":{}}],"eastWestGateways":null,"cluster":"","revision":"gm","defaultRevision":true,"enabled":false}}|see the gloo-mesh-agent helm chart docs for more|
|glooMeshMgmtServer|struct| |Configuration for the glooMeshMgmtServer deployment.|
|glooMeshMgmtServer.relay|struct| |options for configuring relay on the mgmt server|
|glooMeshMgmtServer.relay.tlsSecret|struct| |Reference to a Secret containing TLS Certificates used to secure the Mgmt gRPC Server with TLS.|
|glooMeshMgmtServer.relay.tlsSecret.name|string|relay-server-tls-secret||
|glooMeshMgmtServer.relay.tlsSecret.namespace|string| ||
|glooMeshMgmtServer.relay.signingTlsSecret|struct| |Reference to a Secret containing TLS Certificates used to sign CSRs created by Relay Agents.|
|glooMeshMgmtServer.relay.signingTlsSecret.name|string|relay-tls-signing-secret||
|glooMeshMgmtServer.relay.signingTlsSecret.namespace|string| ||
|glooMeshMgmtServer.relay.tokenSecret|struct| |Reference to a Secret containing a shared Token for authenticating Relay Agents.|
|glooMeshMgmtServer.relay.tokenSecret.name|string|relay-identity-token-secret|Name of the Kubernetes Secret|
|glooMeshMgmtServer.relay.tokenSecret.namespace|string| |Namespace of the Kubernetes Secret|
|glooMeshMgmtServer.relay.tokenSecret.key|string|token|Key value of the data within the Kubernetes Secret|
|glooMeshMgmtServer.relay.disableCa|bool|false||
|glooMeshMgmtServer.relay.disableTokenGeneration|bool|false||
|glooMeshMgmtServer.relay.disableCaCertGeneration|bool|false||
|glooMeshMgmtServer.relay.pushRbac|bool|true|Instruct relay relay to push RBAC resources to the management server. This is needed if you plan to use multi-cluster RBAC in the dashboard.|
|glooMeshMgmtServer.maxGrpcMessageSize|string|4294967295|Specify to set a custom maximum message size for grpc messages sent and received by the Relay server|
|glooMeshMgmtServer.concurrency|uint16|10|The concurrency to use for translation operations. Default is 10.|
|glooMeshMgmtServer.enableClusterLoadBalancing|bool|false|Enable cluster load balancing. Default is false. This feature is experimental and is therefore disabled by default. This feature instructs the mgmt-server replicas to try and auto balance the number of connected clusters by disconnecting a new connecting cluster if the number of connected clusters is greater than it's allotted number. This is calculated based on the number of replicas, and the number of total clusters.|
|glooMeshMgmtServer.statsPort|uint32|9091|Port to pull stats from on gloo-mesh-mgmt-server. Default is 9091.|
|glooMeshMgmtServer|struct| |Configuration for the glooMeshMgmtServer deployment.|
|glooMeshMgmtServer|struct| ||
|glooMeshMgmtServer.image|struct| |Specify the container image|
|glooMeshMgmtServer.image.tag|string| |Tag for the container.|
|glooMeshMgmtServer.image.repository|string|gloo-mesh-mgmt-server|Image name (repository).|
|glooMeshMgmtServer.image.registry|string|gcr.io/gloo-mesh|Image registry.|
|glooMeshMgmtServer.image.pullPolicy|string|IfNotPresent|Image pull policy.|
|glooMeshMgmtServer.image.pullSecret|string| |Image pull secret.|
|glooMeshMgmtServer.Env[]|slice|[{"name":"POD_NAMESPACE","valueFrom":{"fieldRef":{"fieldPath":"metadata.namespace"}}},{"name":"LICENSE_KEY","valueFrom":{"secretKeyRef":{"name":"gloo-mesh-enterprise-license","key":"key","optional":true}}}]|Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshMgmtServer.resources|struct| |Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshMgmtServer.resources.limits|map[string, struct]|null||
|glooMeshMgmtServer.resources.limits.<MAP_KEY>|struct| ||
|glooMeshMgmtServer.resources.limits.<MAP_KEY>|string| ||
|glooMeshMgmtServer.resources.requests|map[string, struct]|{"cpu":"125m","memory":"256Mi"}||
|glooMeshMgmtServer.resources.requests.<MAP_KEY>|struct| ||
|glooMeshMgmtServer.resources.requests.<MAP_KEY>|string| ||
|glooMeshMgmtServer.resources.requests.cpu|struct| ||
|glooMeshMgmtServer.resources.requests.cpu|string|DecimalSI||
|glooMeshMgmtServer.resources.requests.memory|struct| ||
|glooMeshMgmtServer.resources.requests.memory|string|BinarySI||
|glooMeshMgmtServer.securityContext|struct| |Specify container security context. Set to 'false' to omit the security context entirely. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#securitycontext-v1-core) for specification details.|
|glooMeshMgmtServer.securityContext.capabilities|struct| ||
|glooMeshMgmtServer.securityContext.capabilities.add[]|[]string| ||
|glooMeshMgmtServer.securityContext.capabilities.add[]|string| ||
|glooMeshMgmtServer.securityContext.capabilities.drop[]|[]string| ||
|glooMeshMgmtServer.securityContext.capabilities.drop[]|string| ||
|glooMeshMgmtServer.securityContext.privileged|bool| ||
|glooMeshMgmtServer.securityContext.seLinuxOptions|struct| ||
|glooMeshMgmtServer.securityContext.seLinuxOptions.user|string| ||
|glooMeshMgmtServer.securityContext.seLinuxOptions.role|string| ||
|glooMeshMgmtServer.securityContext.seLinuxOptions.type|string| ||
|glooMeshMgmtServer.securityContext.seLinuxOptions.level|string| ||
|glooMeshMgmtServer.securityContext.windowsOptions|struct| ||
|glooMeshMgmtServer.securityContext.windowsOptions.gmsaCredentialSpecName|string| ||
|glooMeshMgmtServer.securityContext.windowsOptions.gmsaCredentialSpec|string| ||
|glooMeshMgmtServer.securityContext.windowsOptions.runAsUserName|string| ||
|glooMeshMgmtServer.securityContext.windowsOptions.hostProcess|bool| ||
|glooMeshMgmtServer.securityContext.runAsUser|int64| ||
|glooMeshMgmtServer.securityContext.runAsGroup|int64| ||
|glooMeshMgmtServer.securityContext.runAsNonRoot|bool| ||
|glooMeshMgmtServer.securityContext.readOnlyRootFilesystem|bool| ||
|glooMeshMgmtServer.securityContext.allowPrivilegeEscalation|bool| ||
|glooMeshMgmtServer.securityContext.procMount|string| ||
|glooMeshMgmtServer.securityContext.seccompProfile|struct| ||
|glooMeshMgmtServer.securityContext.seccompProfile.type|string| ||
|glooMeshMgmtServer.securityContext.seccompProfile.localhostProfile|string| ||
|glooMeshMgmtServer.sidecars|map[string, struct]|{}|Configuration for the deployed containers.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>|struct| |Configuration for the deployed containers.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.image|struct| |Specify the container image|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.image.tag|string| |Tag for the container.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.image.repository|string| |Image name (repository).|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.image.registry|string| |Image registry.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.image.pullPolicy|string| |Image pull policy.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.image.pullSecret|string| |Image pull secret.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.Env[]|slice| |Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources|struct| |Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources.limits|map[string, struct]| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|struct| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources.requests|map[string, struct]| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|struct| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext|struct| |Specify container security context. Set to 'false' to omit the security context entirely. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#securitycontext-v1-core) for specification details.|
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.capabilities|struct| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.capabilities.add[]|[]string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.capabilities.add[]|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.capabilities.drop[]|[]string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.capabilities.drop[]|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.privileged|bool| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.seLinuxOptions|struct| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.seLinuxOptions.user|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.seLinuxOptions.role|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.seLinuxOptions.type|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.seLinuxOptions.level|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.windowsOptions|struct| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.windowsOptions.gmsaCredentialSpecName|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.windowsOptions.gmsaCredentialSpec|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.windowsOptions.runAsUserName|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.windowsOptions.hostProcess|bool| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.runAsUser|int64| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.runAsGroup|int64| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.runAsNonRoot|bool| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.readOnlyRootFilesystem|bool| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.allowPrivilegeEscalation|bool| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.procMount|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.seccompProfile|struct| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.seccompProfile.type|string| ||
|glooMeshMgmtServer.sidecars.<MAP_KEY>.securityContext.seccompProfile.localhostProfile|string| ||
|glooMeshMgmtServer.floatingUserId|bool|false|Allow the pod to be assigned a dynamic user ID.|
|glooMeshMgmtServer.runAsUser|uint32|10101|Static user ID to run the containers as. Unused if floatingUserId is 'true'.|
|glooMeshMgmtServer.serviceType|string|LoadBalancer|Specify the service type. Can be either "ClusterIP", "NodePort", "LoadBalancer", or "ExternalName".|
|glooMeshMgmtServer.ports|map[string, uint32]|{"grpc":9900,"healthcheck":8090}|Specify service ports as a map from port name to port number.|
|glooMeshMgmtServer.ports.<MAP_KEY>|uint32| |Specify service ports as a map from port name to port number.|
|glooMeshMgmtServer.ports.grpc|uint32|9900|Specify service ports as a map from port name to port number.|
|glooMeshMgmtServer.ports.healthcheck|uint32|8090|Specify service ports as a map from port name to port number.|
|glooMeshMgmtServer.DeploymentOverrides|invalid| |Provide arbitrary overrides for the component's [deployment template](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/)|
|glooMeshMgmtServer.ServiceOverrides|invalid| |Provide arbitrary overrides for the component's [service template](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/).|
|glooMeshMgmtServer.enabled|bool|true|Enables or disables creation of the operator deployment/service|
|glooMeshUi|struct| |Configuration for the glooMeshUi deployment.|
|glooMeshUi.settingsName|string|settings|Name of the dashboard settings object to use|
|glooMeshUi.auth|struct| |Authentication configuration|
|glooMeshUi.auth.enabled|bool|false|Require authentication to access the dashboard|
|glooMeshUi.auth.backend|string| |Authentication backend to use. Supports: oidc|
|glooMeshUi.auth.oidc|struct| |Settings for the OpenID Connect backend. Only used when backend is set to 'oidc'.|
|glooMeshUi.auth.oidc.clientId|string| |OIDC client ID|
|glooMeshUi.auth.oidc.clientSecret|string| |Plaintext OIDC client secret. Will be base64 encoded and stored in a secret with the name below.|
|glooMeshUi.auth.oidc.clientSecretName|string| |Name of a secret containing the client secret will be stored at|
|glooMeshUi.auth.oidc.issuerUrl|string| |OIDC Issuer |
|glooMeshUi.auth.oidc.appUrl|string| |URL users will use to access the dashboard|
|glooMeshUi.auth.oidc.session|struct| |Session storage configuration. If omitted a cookie will be used.|
|glooMeshUi.auth.oidc.session.backend|string| |Session backend to use. Supports: cookie, redis|
|glooMeshUi.auth.oidc.session.redis|struct| |Settings for the Redis backend. Only used when backend is set to 'redis'.|
|glooMeshUi.auth.oidc.session.redis.host|string| |Host a Redis instance is accessible at. Set to 'redis.gloo-mesh.svc.cluster.local:6379' to use the included Redis deployment.|
|glooMeshUi.licenseSecretName|string| |this value is optional, but if used will take priority over any other licenseKeys and gloo mesh will look at the licenseSecretName in the namespace that gloo mesh is deployed in.|
|glooMeshUi|struct| |Configuration for the glooMeshUi deployment.|
|glooMeshUi|struct| ||
|glooMeshUi.image|struct| |Specify the container image|
|glooMeshUi.image.tag|string| |Tag for the container.|
|glooMeshUi.image.repository|string|gloo-mesh-apiserver|Image name (repository).|
|glooMeshUi.image.registry|string|gcr.io/gloo-mesh|Image registry.|
|glooMeshUi.image.pullPolicy|string|IfNotPresent|Image pull policy.|
|glooMeshUi.image.pullSecret|string| |Image pull secret.|
|glooMeshUi.Env[]|slice|[{"name":"POD_NAMESPACE","valueFrom":{"fieldRef":{"fieldPath":"metadata.namespace"}}},{"name":"LICENSE_KEY","valueFrom":{"secretKeyRef":{"name":"gloo-mesh-enterprise-license","key":"key","optional":true}}}]|Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshUi.resources|struct| |Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshUi.resources.limits|map[string, struct]|null||
|glooMeshUi.resources.limits.<MAP_KEY>|struct| ||
|glooMeshUi.resources.limits.<MAP_KEY>|string| ||
|glooMeshUi.resources.requests|map[string, struct]|{"cpu":"125m","memory":"256Mi"}||
|glooMeshUi.resources.requests.<MAP_KEY>|struct| ||
|glooMeshUi.resources.requests.<MAP_KEY>|string| ||
|glooMeshUi.resources.requests.cpu|struct| ||
|glooMeshUi.resources.requests.cpu|string|DecimalSI||
|glooMeshUi.resources.requests.memory|struct| ||
|glooMeshUi.resources.requests.memory|string|BinarySI||
|glooMeshUi.securityContext|struct| |Specify container security context. Set to 'false' to omit the security context entirely. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#securitycontext-v1-core) for specification details.|
|glooMeshUi.securityContext.capabilities|struct| ||
|glooMeshUi.securityContext.capabilities.add[]|[]string| ||
|glooMeshUi.securityContext.capabilities.add[]|string| ||
|glooMeshUi.securityContext.capabilities.drop[]|[]string| ||
|glooMeshUi.securityContext.capabilities.drop[]|string| ||
|glooMeshUi.securityContext.privileged|bool| ||
|glooMeshUi.securityContext.seLinuxOptions|struct| ||
|glooMeshUi.securityContext.seLinuxOptions.user|string| ||
|glooMeshUi.securityContext.seLinuxOptions.role|string| ||
|glooMeshUi.securityContext.seLinuxOptions.type|string| ||
|glooMeshUi.securityContext.seLinuxOptions.level|string| ||
|glooMeshUi.securityContext.windowsOptions|struct| ||
|glooMeshUi.securityContext.windowsOptions.gmsaCredentialSpecName|string| ||
|glooMeshUi.securityContext.windowsOptions.gmsaCredentialSpec|string| ||
|glooMeshUi.securityContext.windowsOptions.runAsUserName|string| ||
|glooMeshUi.securityContext.windowsOptions.hostProcess|bool| ||
|glooMeshUi.securityContext.runAsUser|int64| ||
|glooMeshUi.securityContext.runAsGroup|int64| ||
|glooMeshUi.securityContext.runAsNonRoot|bool| ||
|glooMeshUi.securityContext.readOnlyRootFilesystem|bool| ||
|glooMeshUi.securityContext.allowPrivilegeEscalation|bool| ||
|glooMeshUi.securityContext.procMount|string| ||
|glooMeshUi.securityContext.seccompProfile|struct| ||
|glooMeshUi.securityContext.seccompProfile.type|string| ||
|glooMeshUi.securityContext.seccompProfile.localhostProfile|string| ||
|glooMeshUi.sidecars|map[string, struct]|{"console":{"image":{"repository":"gloo-mesh-ui","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":null,"resources":{"requests":{"cpu":"125m","memory":"256Mi"}}},"envoy":{"image":{"repository":"gloo-mesh-envoy","registry":"gcr.io/gloo-mesh","pullPolicy":"IfNotPresent"},"env":[{"name":"ENVOY_UID","value":"0"}],"resources":{"requests":{"cpu":"500m","memory":"256Mi"}}}}|Configuration for the deployed containers.|
|glooMeshUi.sidecars.<MAP_KEY>|struct| |Configuration for the deployed containers.|
|glooMeshUi.sidecars.<MAP_KEY>.image|struct| |Specify the container image|
|glooMeshUi.sidecars.<MAP_KEY>.image.tag|string| |Tag for the container.|
|glooMeshUi.sidecars.<MAP_KEY>.image.repository|string| |Image name (repository).|
|glooMeshUi.sidecars.<MAP_KEY>.image.registry|string| |Image registry.|
|glooMeshUi.sidecars.<MAP_KEY>.image.pullPolicy|string| |Image pull policy.|
|glooMeshUi.sidecars.<MAP_KEY>.image.pullSecret|string| |Image pull secret.|
|glooMeshUi.sidecars.<MAP_KEY>.Env[]|slice| |Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshUi.sidecars.<MAP_KEY>.resources|struct| |Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshUi.sidecars.<MAP_KEY>.resources.limits|map[string, struct]| ||
|glooMeshUi.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|struct| ||
|glooMeshUi.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.resources.requests|map[string, struct]| ||
|glooMeshUi.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|struct| ||
|glooMeshUi.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext|struct| |Specify container security context. Set to 'false' to omit the security context entirely. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#securitycontext-v1-core) for specification details.|
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.capabilities|struct| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.capabilities.add[]|[]string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.capabilities.add[]|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.capabilities.drop[]|[]string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.capabilities.drop[]|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.privileged|bool| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.seLinuxOptions|struct| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.seLinuxOptions.user|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.seLinuxOptions.role|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.seLinuxOptions.type|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.seLinuxOptions.level|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.windowsOptions|struct| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.windowsOptions.gmsaCredentialSpecName|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.windowsOptions.gmsaCredentialSpec|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.windowsOptions.runAsUserName|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.windowsOptions.hostProcess|bool| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.runAsUser|int64| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.runAsGroup|int64| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.runAsNonRoot|bool| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.readOnlyRootFilesystem|bool| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.allowPrivilegeEscalation|bool| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.procMount|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.seccompProfile|struct| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.seccompProfile.type|string| ||
|glooMeshUi.sidecars.<MAP_KEY>.securityContext.seccompProfile.localhostProfile|string| ||
|glooMeshUi.sidecars.console|struct| |Configuration for the deployed containers.|
|glooMeshUi.sidecars.console.image|struct| |Specify the container image|
|glooMeshUi.sidecars.console.image.tag|string| |Tag for the container.|
|glooMeshUi.sidecars.console.image.repository|string|gloo-mesh-ui|Image name (repository).|
|glooMeshUi.sidecars.console.image.registry|string|gcr.io/gloo-mesh|Image registry.|
|glooMeshUi.sidecars.console.image.pullPolicy|string|IfNotPresent|Image pull policy.|
|glooMeshUi.sidecars.console.image.pullSecret|string| |Image pull secret.|
|glooMeshUi.sidecars.console.Env[]|slice|null|Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshUi.sidecars.console.resources|struct| |Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshUi.sidecars.console.resources.limits|map[string, struct]|null||
|glooMeshUi.sidecars.console.resources.limits.<MAP_KEY>|struct| ||
|glooMeshUi.sidecars.console.resources.limits.<MAP_KEY>|string| ||
|glooMeshUi.sidecars.console.resources.requests|map[string, struct]|{"cpu":"125m","memory":"256Mi"}||
|glooMeshUi.sidecars.console.resources.requests.<MAP_KEY>|struct| ||
|glooMeshUi.sidecars.console.resources.requests.<MAP_KEY>|string| ||
|glooMeshUi.sidecars.console.resources.requests.cpu|struct| ||
|glooMeshUi.sidecars.console.resources.requests.cpu|string|DecimalSI||
|glooMeshUi.sidecars.console.resources.requests.memory|struct| ||
|glooMeshUi.sidecars.console.resources.requests.memory|string|BinarySI||
|glooMeshUi.sidecars.console.securityContext|struct| |Specify container security context. Set to 'false' to omit the security context entirely. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#securitycontext-v1-core) for specification details.|
|glooMeshUi.sidecars.console.securityContext.capabilities|struct| ||
|glooMeshUi.sidecars.console.securityContext.capabilities.add[]|[]string| ||
|glooMeshUi.sidecars.console.securityContext.capabilities.add[]|string| ||
|glooMeshUi.sidecars.console.securityContext.capabilities.drop[]|[]string| ||
|glooMeshUi.sidecars.console.securityContext.capabilities.drop[]|string| ||
|glooMeshUi.sidecars.console.securityContext.privileged|bool| ||
|glooMeshUi.sidecars.console.securityContext.seLinuxOptions|struct| ||
|glooMeshUi.sidecars.console.securityContext.seLinuxOptions.user|string| ||
|glooMeshUi.sidecars.console.securityContext.seLinuxOptions.role|string| ||
|glooMeshUi.sidecars.console.securityContext.seLinuxOptions.type|string| ||
|glooMeshUi.sidecars.console.securityContext.seLinuxOptions.level|string| ||
|glooMeshUi.sidecars.console.securityContext.windowsOptions|struct| ||
|glooMeshUi.sidecars.console.securityContext.windowsOptions.gmsaCredentialSpecName|string| ||
|glooMeshUi.sidecars.console.securityContext.windowsOptions.gmsaCredentialSpec|string| ||
|glooMeshUi.sidecars.console.securityContext.windowsOptions.runAsUserName|string| ||
|glooMeshUi.sidecars.console.securityContext.windowsOptions.hostProcess|bool| ||
|glooMeshUi.sidecars.console.securityContext.runAsUser|int64| ||
|glooMeshUi.sidecars.console.securityContext.runAsGroup|int64| ||
|glooMeshUi.sidecars.console.securityContext.runAsNonRoot|bool| ||
|glooMeshUi.sidecars.console.securityContext.readOnlyRootFilesystem|bool| ||
|glooMeshUi.sidecars.console.securityContext.allowPrivilegeEscalation|bool| ||
|glooMeshUi.sidecars.console.securityContext.procMount|string| ||
|glooMeshUi.sidecars.console.securityContext.seccompProfile|struct| ||
|glooMeshUi.sidecars.console.securityContext.seccompProfile.type|string| ||
|glooMeshUi.sidecars.console.securityContext.seccompProfile.localhostProfile|string| ||
|glooMeshUi.sidecars.envoy|struct| |Configuration for the deployed containers.|
|glooMeshUi.sidecars.envoy.image|struct| |Specify the container image|
|glooMeshUi.sidecars.envoy.image.tag|string| |Tag for the container.|
|glooMeshUi.sidecars.envoy.image.repository|string|gloo-mesh-envoy|Image name (repository).|
|glooMeshUi.sidecars.envoy.image.registry|string|gcr.io/gloo-mesh|Image registry.|
|glooMeshUi.sidecars.envoy.image.pullPolicy|string|IfNotPresent|Image pull policy.|
|glooMeshUi.sidecars.envoy.image.pullSecret|string| |Image pull secret.|
|glooMeshUi.sidecars.envoy.Env[]|slice|[{"name":"ENVOY_UID","value":"0"}]|Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshUi.sidecars.envoy.resources|struct| |Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshUi.sidecars.envoy.resources.limits|map[string, struct]|null||
|glooMeshUi.sidecars.envoy.resources.limits.<MAP_KEY>|struct| ||
|glooMeshUi.sidecars.envoy.resources.limits.<MAP_KEY>|string| ||
|glooMeshUi.sidecars.envoy.resources.requests|map[string, struct]|{"cpu":"500m","memory":"256Mi"}||
|glooMeshUi.sidecars.envoy.resources.requests.<MAP_KEY>|struct| ||
|glooMeshUi.sidecars.envoy.resources.requests.<MAP_KEY>|string| ||
|glooMeshUi.sidecars.envoy.resources.requests.cpu|struct| ||
|glooMeshUi.sidecars.envoy.resources.requests.cpu|string|DecimalSI||
|glooMeshUi.sidecars.envoy.resources.requests.memory|struct| ||
|glooMeshUi.sidecars.envoy.resources.requests.memory|string|BinarySI||
|glooMeshUi.sidecars.envoy.securityContext|struct| |Specify container security context. Set to 'false' to omit the security context entirely. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#securitycontext-v1-core) for specification details.|
|glooMeshUi.sidecars.envoy.securityContext.capabilities|struct| ||
|glooMeshUi.sidecars.envoy.securityContext.capabilities.add[]|[]string| ||
|glooMeshUi.sidecars.envoy.securityContext.capabilities.add[]|string| ||
|glooMeshUi.sidecars.envoy.securityContext.capabilities.drop[]|[]string| ||
|glooMeshUi.sidecars.envoy.securityContext.capabilities.drop[]|string| ||
|glooMeshUi.sidecars.envoy.securityContext.privileged|bool| ||
|glooMeshUi.sidecars.envoy.securityContext.seLinuxOptions|struct| ||
|glooMeshUi.sidecars.envoy.securityContext.seLinuxOptions.user|string| ||
|glooMeshUi.sidecars.envoy.securityContext.seLinuxOptions.role|string| ||
|glooMeshUi.sidecars.envoy.securityContext.seLinuxOptions.type|string| ||
|glooMeshUi.sidecars.envoy.securityContext.seLinuxOptions.level|string| ||
|glooMeshUi.sidecars.envoy.securityContext.windowsOptions|struct| ||
|glooMeshUi.sidecars.envoy.securityContext.windowsOptions.gmsaCredentialSpecName|string| ||
|glooMeshUi.sidecars.envoy.securityContext.windowsOptions.gmsaCredentialSpec|string| ||
|glooMeshUi.sidecars.envoy.securityContext.windowsOptions.runAsUserName|string| ||
|glooMeshUi.sidecars.envoy.securityContext.windowsOptions.hostProcess|bool| ||
|glooMeshUi.sidecars.envoy.securityContext.runAsUser|int64| ||
|glooMeshUi.sidecars.envoy.securityContext.runAsGroup|int64| ||
|glooMeshUi.sidecars.envoy.securityContext.runAsNonRoot|bool| ||
|glooMeshUi.sidecars.envoy.securityContext.readOnlyRootFilesystem|bool| ||
|glooMeshUi.sidecars.envoy.securityContext.allowPrivilegeEscalation|bool| ||
|glooMeshUi.sidecars.envoy.securityContext.procMount|string| ||
|glooMeshUi.sidecars.envoy.securityContext.seccompProfile|struct| ||
|glooMeshUi.sidecars.envoy.securityContext.seccompProfile.type|string| ||
|glooMeshUi.sidecars.envoy.securityContext.seccompProfile.localhostProfile|string| ||
|glooMeshUi.floatingUserId|bool|false|Allow the pod to be assigned a dynamic user ID.|
|glooMeshUi.runAsUser|uint32|10101|Static user ID to run the containers as. Unused if floatingUserId is 'true'.|
|glooMeshUi.serviceType|string|ClusterIP|Specify the service type. Can be either "ClusterIP", "NodePort", "LoadBalancer", or "ExternalName".|
|glooMeshUi.ports|map[string, uint32]|{"console":8090,"grpc":10101,"healthcheck":8081}|Specify service ports as a map from port name to port number.|
|glooMeshUi.ports.<MAP_KEY>|uint32| |Specify service ports as a map from port name to port number.|
|glooMeshUi.ports.console|uint32|8090|Specify service ports as a map from port name to port number.|
|glooMeshUi.ports.grpc|uint32|10101|Specify service ports as a map from port name to port number.|
|glooMeshUi.ports.healthcheck|uint32|8081|Specify service ports as a map from port name to port number.|
|glooMeshUi.DeploymentOverrides|invalid| |Provide arbitrary overrides for the component's [deployment template](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/)|
|glooMeshUi.ServiceOverrides|invalid| |Provide arbitrary overrides for the component's [service template](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/).|
|glooMeshUi.enabled|bool|true|Enables or disables creation of the operator deployment/service|
|glooMeshRedis|struct| |Configuration for the glooMeshRedis deployment.|
|glooMeshRedis.addr|string| |Address to use when connecting to redis|
|glooMeshRedis|struct| |Configuration for the glooMeshRedis deployment.|
|glooMeshRedis|struct| ||
|glooMeshRedis.image|struct| |Specify the container image|
|glooMeshRedis.image.tag|string| |Tag for the container.|
|glooMeshRedis.image.repository|string|redis|Image name (repository).|
|glooMeshRedis.image.registry|string|docker.io|Image registry.|
|glooMeshRedis.image.pullPolicy|string|IfNotPresent|Image pull policy.|
|glooMeshRedis.image.pullSecret|string| |Image pull secret.|
|glooMeshRedis.Env[]|slice|[{"name":"MASTER","value":"true"}]|Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshRedis.resources|struct| |Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshRedis.resources.limits|map[string, struct]|null||
|glooMeshRedis.resources.limits.<MAP_KEY>|struct| ||
|glooMeshRedis.resources.limits.<MAP_KEY>|string| ||
|glooMeshRedis.resources.requests|map[string, struct]|{"cpu":"125m","memory":"256Mi"}||
|glooMeshRedis.resources.requests.<MAP_KEY>|struct| ||
|glooMeshRedis.resources.requests.<MAP_KEY>|string| ||
|glooMeshRedis.resources.requests.cpu|struct| ||
|glooMeshRedis.resources.requests.cpu|string|DecimalSI||
|glooMeshRedis.resources.requests.memory|struct| ||
|glooMeshRedis.resources.requests.memory|string|BinarySI||
|glooMeshRedis.securityContext|struct| |Specify container security context. Set to 'false' to omit the security context entirely. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#securitycontext-v1-core) for specification details.|
|glooMeshRedis.securityContext.capabilities|struct| ||
|glooMeshRedis.securityContext.capabilities.add[]|[]string| ||
|glooMeshRedis.securityContext.capabilities.add[]|string| ||
|glooMeshRedis.securityContext.capabilities.drop[]|[]string| ||
|glooMeshRedis.securityContext.capabilities.drop[]|string| ||
|glooMeshRedis.securityContext.privileged|bool| ||
|glooMeshRedis.securityContext.seLinuxOptions|struct| ||
|glooMeshRedis.securityContext.seLinuxOptions.user|string| ||
|glooMeshRedis.securityContext.seLinuxOptions.role|string| ||
|glooMeshRedis.securityContext.seLinuxOptions.type|string| ||
|glooMeshRedis.securityContext.seLinuxOptions.level|string| ||
|glooMeshRedis.securityContext.windowsOptions|struct| ||
|glooMeshRedis.securityContext.windowsOptions.gmsaCredentialSpecName|string| ||
|glooMeshRedis.securityContext.windowsOptions.gmsaCredentialSpec|string| ||
|glooMeshRedis.securityContext.windowsOptions.runAsUserName|string| ||
|glooMeshRedis.securityContext.windowsOptions.hostProcess|bool| ||
|glooMeshRedis.securityContext.runAsUser|int64| ||
|glooMeshRedis.securityContext.runAsGroup|int64| ||
|glooMeshRedis.securityContext.runAsNonRoot|bool| ||
|glooMeshRedis.securityContext.readOnlyRootFilesystem|bool| ||
|glooMeshRedis.securityContext.allowPrivilegeEscalation|bool| ||
|glooMeshRedis.securityContext.procMount|string| ||
|glooMeshRedis.securityContext.seccompProfile|struct| ||
|glooMeshRedis.securityContext.seccompProfile.type|string| ||
|glooMeshRedis.securityContext.seccompProfile.localhostProfile|string| ||
|glooMeshRedis.sidecars|map[string, struct]|{}|Configuration for the deployed containers.|
|glooMeshRedis.sidecars.<MAP_KEY>|struct| |Configuration for the deployed containers.|
|glooMeshRedis.sidecars.<MAP_KEY>.image|struct| |Specify the container image|
|glooMeshRedis.sidecars.<MAP_KEY>.image.tag|string| |Tag for the container.|
|glooMeshRedis.sidecars.<MAP_KEY>.image.repository|string| |Image name (repository).|
|glooMeshRedis.sidecars.<MAP_KEY>.image.registry|string| |Image registry.|
|glooMeshRedis.sidecars.<MAP_KEY>.image.pullPolicy|string| |Image pull policy.|
|glooMeshRedis.sidecars.<MAP_KEY>.image.pullSecret|string| |Image pull secret.|
|glooMeshRedis.sidecars.<MAP_KEY>.Env[]|slice| |Specify environment variables for the container. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvarsource-v1-core) for specification details.|
|glooMeshRedis.sidecars.<MAP_KEY>.resources|struct| |Specify container resource requirements. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#resourcerequirements-v1-core) for specification details.|
|glooMeshRedis.sidecars.<MAP_KEY>.resources.limits|map[string, struct]| ||
|glooMeshRedis.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|struct| ||
|glooMeshRedis.sidecars.<MAP_KEY>.resources.limits.<MAP_KEY>|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.resources.requests|map[string, struct]| ||
|glooMeshRedis.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|struct| ||
|glooMeshRedis.sidecars.<MAP_KEY>.resources.requests.<MAP_KEY>|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext|struct| |Specify container security context. Set to 'false' to omit the security context entirely. See the [Kubernetes documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#securitycontext-v1-core) for specification details.|
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.capabilities|struct| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.capabilities.add[]|[]string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.capabilities.add[]|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.capabilities.drop[]|[]string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.capabilities.drop[]|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.privileged|bool| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.seLinuxOptions|struct| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.seLinuxOptions.user|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.seLinuxOptions.role|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.seLinuxOptions.type|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.seLinuxOptions.level|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.windowsOptions|struct| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.windowsOptions.gmsaCredentialSpecName|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.windowsOptions.gmsaCredentialSpec|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.windowsOptions.runAsUserName|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.windowsOptions.hostProcess|bool| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.runAsUser|int64| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.runAsGroup|int64| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.runAsNonRoot|bool| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.readOnlyRootFilesystem|bool| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.allowPrivilegeEscalation|bool| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.procMount|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.seccompProfile|struct| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.seccompProfile.type|string| ||
|glooMeshRedis.sidecars.<MAP_KEY>.securityContext.seccompProfile.localhostProfile|string| ||
|glooMeshRedis.floatingUserId|bool|false|Allow the pod to be assigned a dynamic user ID.|
|glooMeshRedis.runAsUser|uint32|10101|Static user ID to run the containers as. Unused if floatingUserId is 'true'.|
|glooMeshRedis.serviceType|string|ClusterIP|Specify the service type. Can be either "ClusterIP", "NodePort", "LoadBalancer", or "ExternalName".|
|glooMeshRedis.ports|map[string, uint32]|{"redis":6379}|Specify service ports as a map from port name to port number.|
|glooMeshRedis.ports.<MAP_KEY>|uint32| |Specify service ports as a map from port name to port number.|
|glooMeshRedis.ports.redis|uint32|6379|Specify service ports as a map from port name to port number.|
|glooMeshRedis.DeploymentOverrides|invalid| |Provide arbitrary overrides for the component's [deployment template](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/)|
|glooMeshRedis.ServiceOverrides|invalid| |Provide arbitrary overrides for the component's [service template](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/).|
|glooMeshRedis.enabled|bool|true|Enables or disables creation of the operator deployment/service|
