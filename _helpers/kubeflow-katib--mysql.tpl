##
## If Kubeflow Katib will use the embedded mysql.
## - NOTE: empty means false, non-empty means true
##
{{<- define "kubeflow_katib.use_embedded_mysql" ->}}
{{<- if .Values.kubeflow_common.kubeflow_mysql.enabled ->}}
true
{{<- end ->}}
{{<- end ->}}

##
## The HOSTNAME of the mysql server.
##
{{<- define "kubeflow_katib.mysql.hostname" ->}}
{{<- if tmpl.Exec "kubeflow_katib.use_embedded_mysql" . ->}}
kubeflow-mysql.{{< .Values.kubeflow_common.kubeflow_mysql.namespace >}}.svc.cluster.local
{{<- else ->}}
{{< .Values.kubeflow_apps.katib.mysql.host >}}
{{<- end ->}}
{{<- end ->}}

##
## The PORT of the mysql server.
##
{{<- define "kubeflow_katib.mysql.port" ->}}
{{<- if tmpl.Exec "kubeflow_katib.use_embedded_mysql" . ->}}
3306
{{<- else ->}}
{{< .Values.kubeflow_apps.katib.mysql.port >}}
{{<- end ->}}
{{<- end ->}}

##
## The NAME of the Kubernetes Secret that contains the mysql user.
##
{{<- define "kubeflow_katib.mysql.auth.secret_name" ->}}
{{<- if tmpl.Exec "kubeflow_katib.use_embedded_mysql" . ->}}
{{<- if .Values.kubeflow_common.kubeflow_mysql.kubeflowUser.existingSecret ->}}
{{< .Values.kubeflow_common.kubeflow_mysql.kubeflowUser.existingSecret >}}
{{<- else ->}}
kubeflow-mysql-kubeflow-user
{{<- end ->}}
{{<- else ->}}
{{<- if .Values.kubeflow_apps.katib.mysql.auth.existingSecret ->}}
{{< .Values.kubeflow_apps.katib.mysql.auth.existingSecret >}}
{{<- else ->}}
katib-mysql-secret
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}

##
## The NAMESPACE with the Kubernetes Secret which contains the mysql user.
##  - NOTE: when the embedded mysql is disabled, the secret will be in the kubeflow katib namespace
##
{{<- define "kubeflow_katib.mysql.auth.secret_namespace" ->}}
{{<- if tmpl.Exec "kubeflow_katib.use_embedded_mysql" . ->}}
{{< .Values.kubeflow_common.kubeflow_mysql.namespace >}}
{{<- else ->}}
kubeflow
{{<- end ->}}
{{<- end ->}}

##
## The KEY containing the mysql USERNAME in the Kubernetes Secret.
##
{{<- define "kubeflow_katib.mysql.auth.secret_username_key" ->}}
{{<- if tmpl.Exec "kubeflow_katib.use_embedded_mysql" . ->}}
{{<- if .Values.kubeflow_common.kubeflow_mysql.kubeflowUser.existingSecret ->}}
{{< .Values.kubeflow_common.kubeflow_mysql.kubeflowUser.existingSecretUsernameKey >}}
{{<- else ->}}
username
{{<- end ->}}
{{<- else ->}}
{{<- if .Values.kubeflow_apps.katib.mysql.auth.existingSecret ->}}
{{< .Values.kubeflow_apps.katib.mysql.auth.existingSecretUsernameKey >}}
{{<- else ->}}
username
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}

##
## The KEY containing the mysql PASSWORD in the Kubernetes Secret.
##
{{<- define "kubeflow_katib.mysql.auth.secret_password_key" ->}}
{{<- if tmpl.Exec "kubeflow_katib.use_embedded_mysql" . ->}}
{{<- if .Values.kubeflow_common.kubeflow_mysql.kubeflowUser.existingSecret ->}}
{{< .Values.kubeflow_common.kubeflow_mysql.kubeflowUser.existingSecretPasswordKey >}}
{{<- else ->}}
password
{{<- end ->}}
{{<- else ->}}
{{<- if .Values.kubeflow_apps.katib.mysql.auth.existingSecret ->}}
{{< .Values.kubeflow_apps.katib.mysql.auth.existingSecretPasswordKey >}}
{{<- else ->}}
password
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}