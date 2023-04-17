{{/* Checks for `global.istioNamespace` */}}
{{- if not (eq .Values.global.istioNamespace .Release.Namespace) }}
  {{ required "The `global.istioNamespace` and `.Release.Namespace` must be equal!" nil }}
{{- end }}