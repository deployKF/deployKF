##
## The HTTP endpoint of the gateway (hides port when set to 80)
##
{{<- define "kubeflow_gateway.http_endpoint" ->}}
{{<- if eq (.Values.kubeflow_common.kubeflow_istio_gateway.gateway.ports.http | conv.ToString) "80" ->}}
{{< .Values.kubeflow_common.kubeflow_istio_gateway.gateway.hostname >}}
{{<- else ->}}
{{< .Values.kubeflow_common.kubeflow_istio_gateway.gateway.hostname >}}:{{< .Values.kubeflow_common.kubeflow_istio_gateway.gateway.ports.http >}}
{{<- end ->}}
{{<- end ->}}

##
## The HTTPS endpoint of the gateway (hides port when set to 443)
##
{{<- define "kubeflow_gateway.https_endpoint" ->}}
{{<- if eq (.Values.kubeflow_common.kubeflow_istio_gateway.gateway.ports.https | conv.ToString) "443" ->}}
{{< .Values.kubeflow_common.kubeflow_istio_gateway.gateway.hostname >}}
{{<- else ->}}
{{< .Values.kubeflow_common.kubeflow_istio_gateway.gateway.hostname >}}:{{< .Values.kubeflow_common.kubeflow_istio_gateway.gateway.ports.https >}}
{{<- end ->}}
{{<- end ->}}

##
## If the gateway is using a self-signed SSL certificate
## - NOTE: empty means false, non-empty means true
##
{{<- define "kubeflow_gateway.is_self_signed_cert" ->}}
{{<- if and (.Values.kubeflow_common.kubeflow_istio_gateway.gateway.tls.enabled) (.Values.cluster_dependencies.cert_manager.clusterIssuer.enabled) (eq .Values.cluster_dependencies.cert_manager.clusterIssuer.type "SELF_SIGNED") ->}}
true
{{<- end ->}}
{{<- end ->}}