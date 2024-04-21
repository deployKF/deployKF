## NOTE: because gomplate lazily evaluates templates, we reference this template in
##       `./templates/.gomplateignore_template` to ensure these checks are run

## --------------------------------------------------------------------------------
##
##                                      argocd
##
## --------------------------------------------------------------------------------
{{<- if .Values.argocd.appNamePrefix >}}
  {{<- if .Values.argocd.destination.name >}}
    {{<- if eq .Values.argocd.destination.name "in-cluster" >}}
      {{< fail "`argocd.destination.name` can not be 'in-cluster' if `argocd.appNamePrefix` is set, a single cluster can only have one instance of deployKF" >}}
    {{<- end >}}
  {{<- else >}}
    {{<- if eq .Values.argocd.destination.server "https://kubernetes.default.svc" >}}
      {{< fail "`argocd.destination.server` can not be 'https://kubernetes.default.svc' if `argocd.appNamePrefix` is set, a single cluster can only have one instance of deployKF" >}}
    {{<- end >}}
  {{<- end >}}
{{<- end >}}

## --------------------------------------------------------------------------------
##
##                                  deploykf-core
##
## --------------------------------------------------------------------------------

## --------------------------------------
##         deploykf-istio-gateway
## --------------------------------------
{{<- if not .Values.deploykf_core.deploykf_istio_gateway.gateway.tls.enabled >}}
  {{< fail "`deploykf_core.deploykf_istio_gateway.gateway.tls.enabled` must be true (TIP: to allow HTTP connections on the gateway, set `deploykf_core.deploykf_istio_gateway.gateway.tls.redirect` to false)" >}}
{{<- end >}}

{{<- if and .Values.deploykf_core.deploykf_istio_gateway.gateway.tls.redirect (not .Values.deploykf_core.deploykf_istio_gateway.gateway.tls.clientsUseHttps) >}}
  {{< fail "`deploykf_core.deploykf_istio_gateway.gateway.tls.clientsUseHttps` must be true if `deploykf_core.deploykf_istio_gateway.gateway.tls.redirect` is true" >}}
{{<- end >}}

## --------------------------------------------------------------------------------
##
##                              kubeflow-dependencies
##
## --------------------------------------------------------------------------------

## --------------------------------------
##        kubeflow-argo-workflows
## --------------------------------------
{{<- $default_keyFormat := "artifacts/{{ workflow.namespace }}/{{ workflow.name }}/{{ workflow.creationTimestamp.Y }}/{{ workflow.creationTimestamp.m }}/{{ workflow.creationTimestamp.d }}/{{ pod.name }}" >}}
{{<- if and (not .Values.kubeflow_tools.pipelines.objectStore.useExternal) (ne .Values.kubeflow_dependencies.kubeflow_argo_workflows.artifactRepository.keyFormat $default_keyFormat) >}}
  {{< fail "`kubeflow_dependencies.kubeflow_argo_workflows.artifactRepository.keyFormat` must be left as the default if `kubeflow_tools.pipelines.objectStore.useExternal` is false" >}}
{{<- end >}}

## --------------------------------------------------------------------------------
##
##                                  kubeflow-tools
##
## --------------------------------------------------------------------------------

## --------------------------------------
##               pipelines
## --------------------------------------
{{<- if and .Values.kubeflow_tools.pipelines.objectStore.auth.fromEnv (not .Values.kubeflow_tools.pipelines.objectStore.useExternal) >}}
  {{< fail "`kubeflow_tools.pipelines.objectStore.auth.fromEnv` must be false if `kubeflow_tools.pipelines.objectStore.useExternal` is false" >}}
{{<- end ->}}

{{<- $default_defaultPipelineRoot := "{scheme}://{bucket_name}/v2/artifacts/{profile_name}?region={bucket_region}&endpoint={endpoint}&disableSSL={not_use_ssl}&s3ForcePathStyle=true" >}}
{{<- if and (not .Values.kubeflow_tools.pipelines.objectStore.useExternal) (ne .Values.kubeflow_tools.pipelines.kfpV2.defaultPipelineRoot $default_defaultPipelineRoot) >}}
  {{< fail "`kubeflow_tools.pipelines.kfpV2.defaultPipelineRoot` must be left as the default if `kubeflow_tools.pipelines.objectStore.useExternal` is false" >}}
{{<- end >}}