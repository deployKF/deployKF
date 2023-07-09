##
## The HTTP endpoint of the gateway (hides port when set to 80)
##
{{<- define "deploykf_gateway.http_endpoint" ->}}
{{<- if eq (.Values.deploykf_core.deploykf_istio_gateway.gateway.ports.http | conv.ToString) "80" ->}}
{{< .Values.deploykf_core.deploykf_istio_gateway.gateway.hostname >}}
{{<- else ->}}
{{< .Values.deploykf_core.deploykf_istio_gateway.gateway.hostname >}}:{{< .Values.deploykf_core.deploykf_istio_gateway.gateway.ports.http >}}
{{<- end ->}}
{{<- end ->}}

##
## The HTTPS endpoint of the gateway (hides port when set to 443)
##
{{<- define "deploykf_gateway.https_endpoint" ->}}
{{<- if eq (.Values.deploykf_core.deploykf_istio_gateway.gateway.ports.https | conv.ToString) "443" ->}}
{{< .Values.deploykf_core.deploykf_istio_gateway.gateway.hostname >}}
{{<- else ->}}
{{< .Values.deploykf_core.deploykf_istio_gateway.gateway.hostname >}}:{{< .Values.deploykf_core.deploykf_istio_gateway.gateway.ports.https >}}
{{<- end ->}}
{{<- end ->}}

##
## If the gateway is using a self-signed SSL certificate
## - NOTE: empty means false, non-empty means true
##
{{<- define "deploykf_gateway.is_self_signed_cert" ->}}
{{<- if and (.Values.deploykf_core.deploykf_istio_gateway.gateway.tls.enabled) (.Values.deploykf_dependencies.cert_manager.clusterIssuer.enabled) (eq .Values.deploykf_dependencies.cert_manager.clusterIssuer.type "SELF_SIGNED") ->}}
true
{{<- end ->}}
{{<- end ->}}