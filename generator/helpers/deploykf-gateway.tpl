##
## The public HTTP endpoint of the gateway (hides port when set to 80)
##
{{<- define "deploykf_gateway.http_endpoint" ->}}
{{<- $http_port := .Values.deploykf_core.deploykf_istio_gateway.gatewayService.ports.http | default .Values.deploykf_core.deploykf_istio_gateway.gateway.ports.http >}}
{{<- if eq ($http_port | conv.ToString) "80" ->}}
{{< .Values.deploykf_core.deploykf_istio_gateway.gateway.hostname >}}
{{<- else ->}}
{{< .Values.deploykf_core.deploykf_istio_gateway.gateway.hostname >}}:{{< $http_port >}}
{{<- end ->}}
{{<- end ->}}

##
## The public HTTPS endpoint of the gateway (hides port when set to 443)
##
{{<- define "deploykf_gateway.https_endpoint" ->}}
{{<- $https_port := .Values.deploykf_core.deploykf_istio_gateway.gatewayService.ports.https | default .Values.deploykf_core.deploykf_istio_gateway.gateway.ports.https >}}
{{<- if eq ($https_port | conv.ToString) "443" ->}}
{{< .Values.deploykf_core.deploykf_istio_gateway.gateway.hostname >}}
{{<- else ->}}
{{< .Values.deploykf_core.deploykf_istio_gateway.gateway.hostname >}}:{{< $https_port >}}
{{<- end ->}}
{{<- end ->}}

##
## If the gateway is using a self-signed SSL certificate
## - NOTE: empty means false, non-empty means true
##
{{<- define "deploykf_gateway.is_self_signed_cert" ->}}
{{<- if and (.Values.deploykf_dependencies.cert_manager.enabled) (.Values.deploykf_core.deploykf_istio_gateway.gateway.tls.enabled) (.Values.deploykf_dependencies.cert_manager.clusterIssuer.enabled) (eq .Values.deploykf_dependencies.cert_manager.clusterIssuer.type "SELF_SIGNED") ->}}
true
{{<- end ->}}
{{<- end ->}}