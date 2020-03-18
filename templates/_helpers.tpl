{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "shibboleth.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "shibboleth.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified certificate name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "shibboleth.certificate.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.certificate.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Apache volume mounts
*/}}
{{- define "shibboleth.apache.volumeMounts" }}
{{- range $key := keys (merge .Values.apache.configFiles (include "shibboleth.apache.inlineconfigs" . | fromYaml) (include "shibboleth.apache.fileconfigs" . | fromYaml)) }}
- mountPath: /etc/{{ $key }}
  name: config
  subPath: apache-{{ $key | replace "/" "-" }}
  readOnly: true
{{- end }}
{{- range $key := keys .Values.apache.secretFiles }}
- mountPath: /etc/{{ $key }}
  name: secret
  subPath: apache-{{ $key | replace "/" "-" }}
  readOnly: true
{{- end }}
{{- end }}

{{/*
Apache environment variables
*/}}
{{- define "shibboleth.apache.environment" -}}
{{- $fullname := include "shibboleth.fullname" . -}}
{{- range $key := keys .Values.apache.configEnvs }}
- name: {{ $key }}
  valueFrom:
    configMapKeyRef:
      name: {{ $fullname }}
      key: apache-{{ $key }}
{{- end }}
{{- range $key := keys .Values.apache.secretEnvs }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $fullname }}
      key: apache-{{ $key }}
{{- end }}
{{- end -}}
