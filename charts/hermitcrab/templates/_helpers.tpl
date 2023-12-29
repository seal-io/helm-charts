{{/*
Util to parse iamge tag, remove sha256.
*/}}
{{- define "util.parse_image_tag" -}}
{{- regexReplaceAll "[^a-zA-Z0-9-_.]+" (regexReplaceAll "@sha256:[a-f0-9]+" .image.tag "") "" -}}
{{- end -}}

{{/*
Util to parse image repository.
*/}}
{{- define "util.parse_image" -}}
{{- empty .Values.global.imageRegistry | ternary .image.repository (printf "%s/%s" .Values.global.imageRegistry .image.repository) }}:{{ default "latest" .image.tag }}
{{- end -}}

{{/*
Util to parse storage class.
*/}}
{{- define "util.parse_pvc_storage_class" -}}
{{- default .Values.global.storageClass .pvc.storageClass }}
{{- end }}

{{/*
Get common name.
*/}}
{{- define "common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Get common fullname.
*/}}
{{- define "common.fullname" -}}
    {{- if .Values.fullnameOverride }}
        {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
    {{- else }}
        {{- $name := include "common.name" . }}
        {{- if contains $name .Release.Name }}
            {{- .Release.Name | trunc 63 | trimSuffix "-" }}
        {{- else }}
            {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
        {{- end }}
    {{- end }}
{{- end }}

{{/*
Get common namespace.
*/}}
{{- define "common.namespace" }}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 64 | trimSuffix "-" }}
{{- end }}

{{/*
Get hermitcrab chart name.
*/}}
{{- define "hermitcrab.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get hermitcrab namespace.
*/}}
{{- define "hermitcrab.namespace" -}}
{{ include "common.namespace" . }}
{{- end -}}

{{/*
Get hermitcrab name.
*/}}
{{- define "hermitcrab.name" -}}
{{- printf "%s-%s" (include "common.fullname" .) .Values.hermitcrab.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get hermitcrab labels.
*/}}
{{- define "hermitcrab.labels" -}}
helm.sh/chart: {{ include "hermitcrab.chart" . }}
app.kubernetes.io/part-of: hermitcrab
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
