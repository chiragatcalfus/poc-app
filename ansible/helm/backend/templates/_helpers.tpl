{{- define "backend.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "backend.labels" -}}
app.kubernetes.io/name: {{ include "backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: backend
{{- end }}

{{- define "backend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ .Values.serviceAccount.name | default (printf "%s-sa" .Chart.Name) }}
{{- else -}}
{{ .Values.serviceAccount.name }}
{{- end -}}
{{- end }}
