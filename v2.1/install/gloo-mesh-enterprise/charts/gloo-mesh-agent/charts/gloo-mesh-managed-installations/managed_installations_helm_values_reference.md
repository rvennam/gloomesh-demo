
---
title: "Managed Istio gateway and control plane installations"
description: Reference for Helm values.
weight: 2
---

|Option|Type|Default Value|Description|
|------|----|-----------|-------------|
|images|struct| |Options for the container images|
|images.hub|string| |Istio image repository, such as a Solo.io Istio image repository. If you are using the Solo.io Istio image repo, contact your account representative for a repo key.|
|images.tag|string|1.13.5|Istio image tag|
|controlPlane|struct| |Install an Istio control plane instance in the cluster.|
|controlPlane.enabled|bool|true|Enable installation of the control plane.|
|controlPlane.Overrides|struct|{}|A set of overrides to merge into the Istio operator spec that installs the control plane (https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/)|
|eastWestGateways[]|[]struct|null|Install an east-west gateway in the cluster.|
|eastWestGateways[]|struct| |Install an east-west gateway in the cluster.|
|eastWestGateways[].name|string| |Name of the gateway. Must be unique.|
|eastWestGateways[].enabled|bool| |Enable installation of the gateway.|
|eastWestGateways[].Overrides|struct| |A set of overrides to merge into the Istio operator spec that installs the gateway (https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/)|
|cluster|string| |The cluster that the agent and managed installation are deployed to.|
|revision|string|gm|The name of the Istio revision to be deployed.|
|defaultRevision|bool|true|If true this installation will be used as the default Istio revision for the cluster, anything that uses the 'istio-injection' label will use this revision.|
|enabled|bool|false|Enable the managed installation.|
