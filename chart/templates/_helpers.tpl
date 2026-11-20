{{- define "demo-service.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "demo-service.labels" -}}
app.kubernetes.io/name: {{ include "demo-service.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "demo-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "demo-service.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
