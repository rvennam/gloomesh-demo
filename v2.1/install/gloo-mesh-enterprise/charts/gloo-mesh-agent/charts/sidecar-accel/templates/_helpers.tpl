{{/*
Expand the name of the chart.
*/}}
{{- define "sidecar-accel.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sidecar-accel.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sidecar-accel.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sidecar-accel.labels" -}}
app: {{ .Values.fullname }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sidecar-accel.nodeSelector" -}}
kubernetes.io/os: linux
{{- end }}

{{/*
sidecar-accel clean command
*/}}
{{- define "sidecar-accel.cmd.clean" -}}
- make
- -k
- clean
{{- end }}

{{/*
sidecar-accel args command
*/}}
{{- define "sidecar-accel.cmd.args" -}}
- /app/sidecar-accel
{{- if .Values.debug }}
- -d
{{- end }}
- --ips-file
- {{ .Values.ipsFilePath }}
{{- end }}

{{/*
sidecar-accel init args command
*/}}
{{- define "sidecar-accel.cmd.init.args" -}}
- sh
- -c
- nsenter --net=/host/proc/1/ns/net ip -o addr | awk '{print $4}' | tee {{ .Values.ipsFilePath }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sidecar-accel.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sidecar-accel.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}