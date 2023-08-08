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

{{<- if and .Values.kubeflow_tools.pipelines.kfpV2.minioFix .Values.kubeflow_tools.pipelines.objectStore.useExternal >}}
  {{< fail "`kubeflow_tools.pipelines.kfpV2.minioFix` must be false if `kubeflow_tools.pipelines.objectStore.useExternal` is true" >}}
{{<- end >}}

{{<- $default_defaultPipelineRoot := "minio://{bucket_name}/v2/artifacts/{profile_name}" >}}
{{<- if and (not .Values.kubeflow_tools.pipelines.objectStore.useExternal) (ne .Values.kubeflow_tools.pipelines.kfpV2.defaultPipelineRoot $default_defaultPipelineRoot) >}}
  {{< fail "`kubeflow_tools.pipelines.kfpV2.defaultPipelineRoot` must be left as the default if `kubeflow_tools.pipelines.objectStore.useExternal` is false" >}}
{{<- end >}}