##
## Takes a MinIO policy and a list of additional statements as input and appends the statements to the policy.
## - USAGE: `$policy_yaml := tmpl.Exec "deploykf_minio_policies.append_to_user" (dict "prev_policy" $prev_policy dict "statements" $statements)`
##
{{<- define "deploykf_minio_policies.append_to_user" ->}}
{{<- $statements := .statements >}}
{{<- $prev_policy := .prev_policy >}}
Version: "2012-10-17"
Statement:
{{<- range $statement := $statements >}}
- Effect: {{< $statement.Effect >}}
  Action:
  {{<- range $action := $statement.Action >}}
  - {{< $action >}}
  {{<- end >}}
  Resource:
  {{<- range $resource := $statement.Resource >}}
  - {{< $resource >}}
  {{<- end >}}
{{<- end >}}
{{<- range $prev_statement := $prev_policy.Statement >}}
- Effect: {{< $prev_statement.Effect >}}
  Action:
  {{<- range $action := $prev_statement.Action >}}
  - {{< $action >}}
  {{<- end >}}
  Resource:
  {{<- range $resource := $prev_statement.Resource >}}
  - {{< $resource >}}
  {{<- end >}}
{{<- end >}}
{{<- end ->}}
