##
## The `spec.source` section of a KUSTOMIZE ArgoCD Application which uses the deploykf plugin.
## - USAGE: `$argocd_source := tmpl.Exec "argocd.plugin_source.kustomize" (dict "output_kustomize_path" $output_kustomize_path)`
##
{{<- define "argocd.plugin_source.kustomize" ->}}
{{< tmpl.Exec "argocd.plugin_source" (dict "output_kustomize_path" .output_kustomize_path "output_helm_path" nil "output_helm_values_files" nil) >}}
{{<- end >}}

##
## The `spec.source` section of a HELM ArgoCD Application which uses the deploykf plugin.
## - USAGE: `$argocd_source := tmpl.Exec "argocd.plugin_source.helm" (dict "output_helm_path" $output_helm_path "output_helm_values_files" $output_helm_values_files)`
##
{{<- define "argocd.plugin_source.helm" ->}}
{{< tmpl.Exec "argocd.plugin_source" (dict "output_kustomize_path" nil "output_helm_path" .output_helm_path "output_helm_values_files" .output_helm_values_files) >}}
{{<- end >}}

##
## The `spec.source` section of a ArgoCD Application which uses the deploykf plugin.
## - USAGE: `$argocd_source := tmpl.Exec "argocd.plugin_source" (dict "output_kustomize_path" "xxxx" output_helm_path" "xxxx" "output_helm_values_files" (coll.Slice "xxxx"))`
##
{{<- define "argocd.plugin_source" ->}}
repoURL: {{< getenv "ARGOCD_APP_SOURCE_REPO_URL" | required "required env-var 'ARGOCD_APP_SOURCE_REPO_URL' is not set" | quote >}}
targetRevision: {{< getenv "ARGOCD_APP_SOURCE_TARGET_REVISION" | required "required env-var 'ARGOCD_APP_SOURCE_TARGET_REVISION' is not set" | quote >}}
path: {{< getenv "ARGOCD_APP_SOURCE_PATH" | required "required env-var 'ARGOCD_APP_SOURCE_PATH' is not set" | quote >}}
plugin:
  name: "deploykf"
  {{<- $output_kustomize_path := .output_kustomize_path >}}
  {{<- $output_helm_path := .output_helm_path >}}
  {{<- $output_helm_values_files := .output_helm_values_files >}}
  {{<- $source_version := getenv "PARAM_SOURCE_VERSION" >}}
  {{<- $source_path := getenv "PARAM_SOURCE_PATH" >}}
  {{<- $values := getenv "PARAM_VALUES" >}}
  {{<- $values_files := coll.Slice >}}
  {{<- $parameters := getenv "ARGOCD_APP_PARAMETERS" | jsonArray >}}
  {{<- range $param := $parameters >}}
    {{<- if eq $param.name "values_files" >}}
    {{<- $values_files = $param.array >}}
    {{<- end >}}
  {{<- end >}}
  parameters:
    {{<- if $output_kustomize_path >}}
    - name: "output_kustomize_path"
      string: {{< $output_kustomize_path | quote >}}
    {{<- end >}}
    {{<- if $output_helm_path >}}
    - name: "output_helm_path"
      string: {{< $output_helm_path | quote >}}
    {{<- end >}}
    {{<- if $output_helm_values_files >}}
    - name: "output_helm_values_files"
      array: {{< $output_helm_values_files | toJSON >}}
    {{<- end >}}
    {{<- if $source_version >}}
    - name: "source_version"
      string: {{< $source_version | quote >}}
    {{<- end >}}
    {{<- if $source_path >}}
    - name: "source_path"
      string: {{< $source_path | quote >}}
    {{<- end >}}
    {{<- if $values >}}
    - name: "values"
      string: {{< $values | quote >}}
    {{<- end >}}
    {{<- if $values_files >}}
    - name: "values_files"
      array: {{< $values_files | toJSON >}}
    {{<- end >}}
{{<- end >}}

##
## If the configured ArgoCD destination is NOT the cluster where the ArgoCD is running.
## - NOTE: empty means false, non-empty means true
##
{{<- define "argocd.destination.is_remote" ->}}
{{<- if .Values.argocd.destination.name ->}}
{{<- if ne .Values.argocd.destination.name "in-cluster" ->}}
true
{{<- end ->}}
{{<- else ->}}
{{<- if ne .Values.argocd.destination.server "https://kubernetes.default.svc" ->}}
true
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}