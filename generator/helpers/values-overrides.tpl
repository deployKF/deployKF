##
## Used to generate `values-overrides.yaml` files
## - USAGE: {{<- template "deploykf.values_overrides" (coll.Merge . (dict "overrides_path" ".Values.deploykf_dependencies.cert_manager.values")) >}}
##
{{<- define "deploykf.values_overrides" ->}}
{{<- $values_overrides := coll.JSONPath .overrides_path .  >}}
{{<- if $values_overrides >}}
{{<- if isKind "string" $values_overrides >}}
{{<- (tpl $values_overrides .) | yaml | toYAML >}}
{{<- else if isKind "map" $values_overrides >}}
{{<- $values_overrides | toYAML >}}
{{<- else >}}
{{<- fail (printf "`%s` must be string or map, but got %s" .overrides_path (kind $values_overrides)) >}}
{{<- end >}}
{{<- end >}}
{{<- end ->}}