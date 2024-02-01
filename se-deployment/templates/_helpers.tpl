{{/*
Expand the name of the chart.
*/}}
{{- define "se-deployment.name" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "se-deployment.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "se-deployment.labels" -}}
helm.sh/chart: {{ include "se-deployment.chart" . }}
{{ include "se-deployment.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/owned-by: {{ .Values.owner }}
owner: {{ required  "Missing 'owner' value" .Values.owner }}
app: {{ .Release.Name }}
version: {{ .Values.image.tag | quote }}
stack: {{ required "Missing 'stack' value" .Values.stack }}
environment: {{ required "Missing 'environment' value" .Values.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "se-deployment.selectorLabels" -}}
app.kubernetes.io/name: {{ include "se-deployment.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "se-deployment.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "se-deployment.name" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the aws iam resource to use
*/}}
{{- define "se-deployment.iamResourceName" -}}
{{- if .Values.iam.create }}
{{- default (include "se-deployment.name" .) .Values.iam.name }}
{{- end }}
{{- end }}

{{/*
Inject extra environment vars in the format key:value, if populated
*/}}
{{- define "se-deployment.env" -}}
{{- range $key, $value := .env }}
- name: {{ printf "%s" $key | replace "." "_" |  quote }}
  value: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{/*
Inject extra environment populated by secrets, if populated
*/}}
{{- define "se-deployment.envFromSecret" -}}
{{- range .envFromSecret }}
- name: {{ .envName }}
  valueFrom:
   secretKeyRef:
     name: {{ .secretName }}
     key: {{ .secretKey }}
{{- end -}}
{{- end -}}

{{/*
Inject extra environment populated by configmaps, if populated
*/}}
{{- define "se-deployment.envFromConfigMap" -}}
{{- range .envFromConfigMap }}
- name: {{ .envName }}
  valueFrom:
    configMapKeyRef:
      name: {{ .configMapName }}
      key: {{ .configMapKey }}
{{- end -}}
{{- end -}}

{{/*
Inject extra environment populated by secrets, if populated
*/}}
{{- define "se-deployment.envFromSecretRef" -}}
{{- range .envFromSecretRef }}
- secretRef:
    name: {{ . }}
{{- end -}}
{{- end -}}

{{/*
Inject extra environment populated by configmaps, if populated
*/}}
{{- define "se-deployment.envFromConfigMapRef" -}}
{{- range .envFromConfigMapRef }}
- configMapRef:
    name: {{ . }}
{{- end -}}
{{- end -}}
