##
## If Kubeflow Pipelines will use the embedded minio.
## - NOTE: empty means false, non-empty means true
##
{{<- define "kubeflow_pipelines.use_embedded_minio" ->}}
{{<- if not .Values.kubeflow_tools.pipelines.objectStore.useExternal ->}}
{{<- if .Values.deploykf_opt.deploykf_minio.enabled ->}}
true
{{<- else if .Values.kubeflow_tools.pipelines.enabled ->}}
{{< fail "`deploykf_opt.deploykf_minio.enabled` must be true if `kubeflow_tools.pipelines.objectStore.useExternal` is false" >}}
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}

##
## The HOSTNAME of the object store api.
##
{{<- define "kubeflow_pipelines.object_store.hostname" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
minio-api.{{< .Values.deploykf_opt.deploykf_minio.namespace >}}.svc.cluster.local
{{<- else ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.host >}}
{{<- end ->}}
{{<- end ->}}

##
## The PORT of the object store api.
##
{{<- define "kubeflow_pipelines.object_store.port" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
9000
{{<- else ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.port | default "" >}}
{{<- end ->}}
{{<- end ->}}

##
## The ENDPOINT (hostname with port) of the object store api.
##
{{<- define "kubeflow_pipelines.object_store.endpoint" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
minio-api.{{< .Values.deploykf_opt.deploykf_minio.namespace >}}.svc.cluster.local:9000
{{<- else ->}}
{{<- if .Values.kubeflow_tools.pipelines.objectStore.port ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.host >}}:{{< .Values.kubeflow_tools.pipelines.objectStore.port >}}
{{<- else ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.host >}}
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}

##
## If SSL/HTTPS WILL be used for the object store api.
##
{{<- define "kubeflow_pipelines.object_store.use_ssl" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
false
{{<- else ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.useSSL >}}
{{<- end ->}}
{{<- end ->}}

##
## If SSL/HTTPS WILL NOT be used for the object store api
##
{{<- define "kubeflow_pipelines.object_store.not_use_ssl" ->}}
{{<- if eq (tmpl.Exec "kubeflow_pipelines.object_store.use_ssl" . | conv.ToString | toLower) "true" ->}}
false
{{<- else if eq (tmpl.Exec "kubeflow_pipelines.object_store.use_ssl" . | conv.ToString | toLower) "false" ->}}
true
{{<- else ->}}
{{< fail "invalid `kubeflow_tools.pipelines.objectStore.useSSL`, must be 'true' or 'false'" >}}
{{<- end >}}
{{<- end ->}}

##
## The NAME of the Kubernetes Secret that contains the object store access/secret keys.
##  - NOTE: this is the SOURCE secret, the manifests actually use "kubeflow_pipelines.object_store.auth.secret_name"
##    as we clone the secret (with Kyverno) into the kubeflow and profile namespaces
##
{{<- define "kubeflow_pipelines.object_store.auth.source_secret_name" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
{{<- if .Values.deploykf_opt.deploykf_minio.rootUser.existingSecret ->}}
{{< .Values.deploykf_opt.deploykf_minio.rootUser.existingSecret >}}
{{<- else ->}}
minio-root-user
{{<- end ->}}
{{<- else ->}}
{{<- if .Values.kubeflow_tools.pipelines.objectStore.auth.existingSecret ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.auth.existingSecret >}}
{{<- else ->}}
pipelines-bucket-secret
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}

##
## The NAMESPACE with the Kubernetes Secret which contains the object store access/secret keys.
##  - NOTE: when the embedded minio is disabled, the SOURCE secret will be in the kubeflow namespace
##
{{<- define "kubeflow_pipelines.object_store.auth.source_secret_namespace" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
{{< .Values.deploykf_opt.deploykf_minio.namespace >}}
{{<- else ->}}
kubeflow
{{<- end ->}}
{{<- end ->}}

##
## The NAME of the Kubernetes Secret that contains object store access/secret keys (in kubeflow and profile namespaces).
##
{{<- define "kubeflow_pipelines.object_store.auth.secret_name" ->}}
cloned--pipelines-bucket-secret
{{<- end ->}}

##
## The KEY containing the object store ACCESS_KEY in the Kubernetes Secret.
##
{{<- define "kubeflow_pipelines.object_store.auth.access_key_key" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
{{<- if .Values.deploykf_opt.deploykf_minio.rootUser.existingSecret ->}}
{{< .Values.deploykf_opt.deploykf_minio.rootUser.existingSecretUsernameKey >}}
{{<- else ->}}
username
{{<- end ->}}
{{<- else ->}}
{{<- if .Values.kubeflow_tools.pipelines.objectStore.auth.existingSecret ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.auth.existingSecretAccessKeyKey >}}
{{<- else ->}}
ACCESS_KEY
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}

##
## The KEY containing the object store SECRET_KEY in the Kubernetes Secret.
##
{{<- define "kubeflow_pipelines.object_store.auth.secret_key_key" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
{{<- if .Values.deploykf_opt.deploykf_minio.rootUser.existingSecret ->}}
{{< .Values.deploykf_opt.deploykf_minio.rootUser.existingSecretPasswordKey >}}
{{<- else ->}}
password
{{<- end ->}}
{{<- else ->}}
{{<- if .Values.kubeflow_tools.pipelines.objectStore.auth.existingSecret ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.auth.existingSecretSecretKeyKey >}}
{{<- else ->}}
SECRET_KEY
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}