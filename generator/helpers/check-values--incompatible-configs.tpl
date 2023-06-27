## NOTE: because gomplate lazily evaluates templates, we reference this template in
##       `./templates/.gomplateignore_template` to ensure these checks are run

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