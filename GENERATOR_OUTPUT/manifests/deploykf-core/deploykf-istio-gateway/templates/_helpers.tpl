{{/*
Override the selector labels of the inner "gateway" chart.
WARNING: note, we use gomplate to set this as a static string, because outer values are not visible to the inner "gateway" chart.
*/}}
{{- define "gateway.selectorLabels" -}}
app: deploykf-gateway
istio: deploykf-gateway
{{- end -}}

{{/*
Define the `helm.sh/chart` label used by this chart.
*/}}
{{- define "deploykf-istio-gateway.labels.chart" -}}
{{- printf "%s-%s" (.Chart.Name | trunc 54) (.Chart.Version) | replace "+" "_" | trunc 63 -}}
{{- end -}}

{{/*
Define the `app.kubernetes.io/name` label used by this chart.
*/}}
{{- define "deploykf-istio-gateway.labels.name" -}}
{{- .Chart.Name -}}
{{- end -}}