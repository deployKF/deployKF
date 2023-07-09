## NOTE: because gomplate lazily evaluates templates, we reference this template in
##       `./templates/.gomplateignore_template` to ensure these checks are run

## --------------------------------------------------------------------------------
##
##                                  deploykf-core
##
## --------------------------------------------------------------------------------

## --------------------------------------
##             deploykf-auth
## --------------------------------------
{{<- if not .Values.deploykf_core.deploykf_auth.enabled ->}}
  {{< fail "`deploykf_core.deploykf_auth.enabled` must be true, 'deploykf-auth' is a required component" >}}
{{<- end ->}}

## --------------------------------------
##          deploykf-dashboard
## --------------------------------------
{{<- if not .Values.deploykf_core.deploykf_dashboard.enabled ->}}
  {{< fail "`deploykf_core.deploykf_dashboard.enabled` must be true, 'deploykf-dashboard' is a required component" >}}
{{<- end ->}}

## --------------------------------------
##        deploykf-istio-gateway
## --------------------------------------
{{<- if not .Values.deploykf_core.deploykf_istio_gateway.enabled ->}}
  {{< fail "`deploykf_core.deploykf_istio_gateway.enabled` must be true, 'deploykf-istio-gateway' is a required component" >}}
{{<- end ->}}

## --------------------------------------
##      deploykf-profiles-generator
## --------------------------------------
{{<- if not .Values.deploykf_core.deploykf_profiles_generator.enabled ->}}
  {{< fail "`deploykf_core.deploykf_profiles_generator.enabled` must be true, 'deploykf-profiles-generator' is a required component" >}}
{{<- end ->}}

## --------------------------------------------------------------------------------
##
##                              kubeflow-dependencies
##
## --------------------------------------------------------------------------------

## --------------------------------------
##        kubeflow-argo-workflows
## --------------------------------------
{{<- if and (.Values.kubeflow_tools.pipelines.enabled) (not .Values.kubeflow_dependencies.kubeflow_argo_workflows.enabled) ->}}
  {{< fail "`kubeflow_dependencies.kubeflow_argo_workflows.enabled` must be true if `kubeflow_tools.pipelines.enabled` is true, you can't currently bring your own argo-workflows)" >}}
{{<- end ->}}