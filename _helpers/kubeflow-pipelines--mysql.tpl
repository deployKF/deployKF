##
## If Kubeflow Pipelines will use the embedded mysql.
## - NOTE: empty means false, non-empty means true
##
{{<- define "kubeflow_pipelines.use_embedded_mysql" ->}}
{{<- if .Values.kubeflow_common.kubeflow_mysql.enabled ->}}
true
{{<- end ->}}
{{<- end ->}}

##
## The HOSTNAME of the mysql server.
##
{{<- define "kubeflow_pipelines.mysql.hostname" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_mysql" . ->}}
kubeflow-mysql.{{< .Values.kubeflow_common.kubeflow_mysql.namespace >}}.svc.cluster.local
{{<- else ->}}
{{< .Values.kubeflow_apps.pipelines.mysql.host >}}
{{<- end ->}}
{{<- end ->}}

##
## The PORT of the mysql server.
##
{{<- define "kubeflow_pipelines.mysql.port" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_mysql" . ->}}
3306
{{<- else ->}}
{{< .Values.kubeflow_apps.pipelines.mysql.port >}}
{{<- end ->}}
{{<- end ->}}

##
## The NAME of the Kubernetes Secret that contains the mysql user.
##  - NOTE: this is the SOURCE secret, the manifests actually use "kubeflow_pipelines.mysql.auth.secret_name"
##    which accounts for cases when this secret is replicated (by Kyverno) into the kubeflow namespace
##
{{<- define "kubeflow_pipelines.mysql.auth.source_secret_name" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_mysql" . ->}}
{{<- if .Values.kubeflow_common.kubeflow_mysql.kubeflowUser.existingSecret ->}}
{{< .Values.kubeflow_common.kubeflow_mysql.kubeflowUser.existingSecret >}}
{{<- else ->}}
kubeflow-mysql-kubeflow-user
{{<- end ->}}
{{<- else ->}}
{{<- if .Values.kubeflow_apps.pipelines.mysql.auth.existingSecret ->}}
{{< .Values.kubeflow_apps.pipelines.mysql.auth.existingSecret >}}
{{<- else ->}}
pipelines-mysql-secret
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}

##
## The NAMESPACE with the Kubernetes Secret which contains the mysql user.
##  - NOTE: when the embedded mysql is disabled, the SOURCE secret will be in the kubeflow namespace
##
{{<- define "kubeflow_pipelines.mysql.auth.source_secret_namespace" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_mysql" . ->}}
{{< .Values.kubeflow_common.kubeflow_mysql.namespace >}}
{{<- else ->}}
kubeflow
{{<- end ->}}
{{<- end ->}}

##
## If Kubeflow Pipelines will use a secret cloned by Kyverno.
## - NOTE: empty means false, non-empty means true
##
{{<- define "kubeflow_pipelines.mysql.auth.secret_is_cloned" ->}}
{{<- if ne (tmpl.Exec "kubeflow_pipelines.mysql.auth.source_secret_namespace" .) "kubeflow" >}}
true
{{<- end ->}}
{{<- end ->}}

##
## The NAME of the Kubernetes Secret that contains the mysql user (in the kubeflow namespace).
##
{{<- define "kubeflow_pipelines.mysql.auth.secret_name" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.mysql.auth.secret_is_cloned" . ->}}
cloned--pipelines-mysql-secret
{{<- else ->}}
{{<- tmpl.Exec "kubeflow_pipelines.mysql.auth.source_secret_name" . ->}}
{{<- end ->}}
{{<- end ->}}

##
## The KEY containing the mysql USERNAME in the Kubernetes Secret.
##
{{<- define "kubeflow_pipelines.mysql.auth.secret_username_key" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_mysql" . ->}}
{{<- if .Values.kubeflow_common.kubeflow_mysql.kubeflowUser.existingSecret ->}}
{{< .Values.kubeflow_common.kubeflow_mysql.kubeflowUser.existingSecretUsernameKey >}}
{{<- else ->}}
username
{{<- end ->}}
{{<- else ->}}
{{<- if .Values.kubeflow_apps.pipelines.mysql.auth.existingSecret ->}}
{{< .Values.kubeflow_apps.pipelines.mysql.auth.existingSecretUsernameKey >}}
{{<- else ->}}
username
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}

##
## The KEY containing the mysql PASSWORD in the Kubernetes Secret.
##
{{<- define "kubeflow_pipelines.mysql.auth.secret_password_key" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_mysql" . ->}}
{{<- if .Values.kubeflow_common.kubeflow_mysql.kubeflowUser.existingSecret ->}}
{{< .Values.kubeflow_common.kubeflow_mysql.kubeflowUser.existingSecretPasswordKey >}}
{{<- else ->}}
password
{{<- end ->}}
{{<- else ->}}
{{<- if .Values.kubeflow_apps.pipelines.mysql.auth.existingSecret ->}}
{{< .Values.kubeflow_apps.pipelines.mysql.auth.existingSecretPasswordKey >}}
{{<- else ->}}
password
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}