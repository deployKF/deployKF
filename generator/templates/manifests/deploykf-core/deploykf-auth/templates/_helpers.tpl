{{/*
Define the `helm.sh/chart` label used by this chart.
*/}}
{{- define "deploykf-auth.labels.chart" -}}
{{- printf "%s-%s" (.Chart.Name | trunc 54) (.Chart.Version) | replace "+" "_" | trunc 63 -}}
{{- end -}}

{{/*
Define the `app.kubernetes.io/name` label used by this chart.
*/}}
{{- define "deploykf-auth.labels.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{/*
Define a template for staticPasswords secret environment variable names.
- USAGE: {{- $password_env := include "deploykf-auth.dex.password_env" (dict "name" $user.password.existingSecret "key" $user.password.existingSecretKey) }}
*/}}
{{- define "deploykf-auth.dex.password_env" -}}
{{- $secret_name := .name -}}
{{- $secret_key := .key -}}
{{- regexReplaceAll "\\W+" (printf "STATIC_PASSWORD__%s__%s" .name .key) "_" -}}
{{- end -}}

{{/*
Define a template for connectors secret environment variable names.
- USAGE: {{- $connector_env := include "deploykf-auth.dex.connector_env" (dict "name" $connector.existingSecret "key" $connector.existingSecretKey) }}
*/}}
{{- define "deploykf-auth.dex.connector_env" -}}
{{- $secret_name := .name -}}
{{- $secret_key := .key -}}
{{- regexReplaceAll "\\W+" (printf "CONNECTOR__%s__%s" .name .key) "_" -}}
{{- end -}}