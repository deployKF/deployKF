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
## If the object store is AWS S3.
## - NOTE: empty means false, non-empty means true
##
{{<- define "kubeflow_pipelines.object_store.is_aws_s3" ->}}
{{<- if not (tmpl.Exec "kubeflow_pipelines.use_embedded_minio" .) ->}}
{{<- if .Values.kubeflow_tools.pipelines.objectStore.host | regexp.Match `^.*s3.*amazonaws.com.*$` ->}}
true
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}

##
## The HOSTNAME of the object store api.
##
{{<- define "kubeflow_pipelines.object_store.hostname" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
deploykf-minio-api.{{< .Values.deploykf_opt.deploykf_minio.namespace >}}.svc.cluster.local
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
{{<- if and (tmpl.Exec "kubeflow_pipelines.object_store.is_aws_s3" .) (.Values.kubeflow_tools.pipelines.objectStore.port) ->}}
{{< fail "`kubeflow_tools.pipelines.objectStore.port` must be empty if using AWS S3" >}}
{{<- else ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.port | default "" >}}
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}

##
## The ENDPOINT (hostname with port) of the object store api.
##
{{<- define "kubeflow_pipelines.object_store.endpoint" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
deploykf-minio-api.{{< .Values.deploykf_opt.deploykf_minio.namespace >}}.svc.cluster.local:9000
{{<- else ->}}
{{<- if .Values.kubeflow_tools.pipelines.objectStore.port ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.host >}}:{{< .Values.kubeflow_tools.pipelines.objectStore.port >}}
{{<- else ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.host >}}
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}

##
## If SSL/HTTPS will be used for the object store api.
## - NOTE: false is represented as 'false', true is represented as 'true'
##         remember to `... | conv.ToBool` if you need a boolean value
##
{{<- define "kubeflow_pipelines.object_store.use_ssl" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
false
{{<- else ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.useSSL | conv.ToBool >}}
{{<- end ->}}
{{<- end ->}}

##
## If SSL/HTTPS WILL NOT be used for the object store api
## - NOTE: false is represented as 'false', true is represented as 'true'
##         remember to `... | conv.ToBool` if you need a boolean value
##
{{<- define "kubeflow_pipelines.object_store.not_use_ssl" ->}}
{{<- if eq (tmpl.Exec "kubeflow_pipelines.object_store.use_ssl" . | conv.ToString | toLower) "true" ->}}
false
{{<- else if eq (tmpl.Exec "kubeflow_pipelines.object_store.use_ssl" . | conv.ToString | toLower) "false" ->}}
true
{{<- else ->}}
{{< fail "invalid `kubeflow_tools.pipelines.objectStore.useSSL`, must be 'true' or 'false'" >}}
{{<- end ->}}
{{<- end ->}}

##
## The ENDPOINT_URL (schema, hostname, and port) of the object store api.
##
{{<- define "kubeflow_pipelines.object_store.endpoint_url" ->}}
{{<- if (tmpl.Exec "kubeflow_pipelines.object_store.use_ssl" .) | conv.ToBool ->}}
https://{{< tmpl.Exec "kubeflow_pipelines.object_store.endpoint" . >}}
{{<- else ->}}
http://{{< tmpl.Exec "kubeflow_pipelines.object_store.endpoint" . >}}
{{<- end ->}}
{{<- end ->}}

##
## The NAME of the Kubernetes Secret that contains the object store access/secret keys.
##  - NOTE: this is the SOURCE secret, the manifests actually use "kubeflow_pipelines.object_store.auth.secret_name"
##    as we clone the secret (with Kyverno) into the kubeflow and argo-workflows namespaces
##
{{<- define "kubeflow_pipelines.object_store.auth.source_secret_name" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
generated--kubeflow-pipelines--backend-object-store-auth
{{<- else ->}}
{{<- if .Values.kubeflow_tools.pipelines.objectStore.auth.existingSecret ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.auth.existingSecret >}}
{{<- else ->}}
kubeflow-pipelines--backend-object-store-auth
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
## The NAME of the Kubernetes Secret that contains object store access/secret keys.
##  - NOTE: this is the secret name AFTER it is cloned into the kubeflow and argo-workflows namespaces
##
{{<- define "kubeflow_pipelines.object_store.auth.secret_name" ->}}
cloned--kubeflow-pipelines--backend-object-store-auth
{{<- end ->}}

##
## The KEY containing the object store ACCESS_KEY in the Kubernetes Secret.
##
{{<- define "kubeflow_pipelines.object_store.auth.access_key_key" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
access_key
{{<- else ->}}
{{<- if .Values.kubeflow_tools.pipelines.objectStore.auth.existingSecret ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.auth.existingSecretAccessKeyKey >}}
{{<- else ->}}
access_key
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}

##
## The KEY containing the object store SECRET_KEY in the Kubernetes Secret.
##
{{<- define "kubeflow_pipelines.object_store.auth.secret_key_key" ->}}
{{<- if tmpl.Exec "kubeflow_pipelines.use_embedded_minio" . ->}}
secret_key
{{<- else ->}}
{{<- if .Values.kubeflow_tools.pipelines.objectStore.auth.existingSecret ->}}
{{< .Values.kubeflow_tools.pipelines.objectStore.auth.existingSecretSecretKeyKey >}}
{{<- else ->}}
secret_key
{{<- end ->}}
{{<- end ->}}
{{<- end ->}}

##
## A template for a MinIO policy JSON that grants bucket read/write access for the KFP BACKEND pods.
## - USAGE: `$policy_json := tmpl.Exec "kubeflow_pipelines.object_store.auth.minio_policy" (dict "bucket_name" "my_bucket")`
##
{{<- define "kubeflow_pipelines.object_store.auth.minio_policy" ->}}
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::{{< .bucket_name >}}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::{{< .bucket_name >}}/artifacts/*",
        "arn:aws:s3:::{{< .bucket_name >}}/pipelines/*",
        "arn:aws:s3:::{{< .bucket_name >}}/v2/artifacts/*"
      ]
    }
  ]
}
{{<- end ->}}

##
## The NAME of the CLONED Kubernetes Secret that contains object store access/secret keys (in profile namespaces).
## - NOTE: this value is used regardless of the "source" secret name, and is shared across all profiles
##
{{<- define "kubeflow_pipelines.object_store.profile.cloned_secret_name" ->}}
cloned--pipelines-object-store-auth
{{<- end ->}}

##
## The KEY containing the object store ACCESS_KEY in the GENERATED Kubernetes Secrets (in profile namespaces).
##
{{<- define "kubeflow_pipelines.object_store.profile.generated_access_key_key" ->}}
{{< .Values.deploykf_core.deploykf_profiles_generator.profileDefaults.tools.kubeflowPipelines.objectStoreAuth.existingSecretAccessKeyKey >}}
{{<- end ->}}

##
## The KEY containing the object store SECRET_KEY in the GENERATED Kubernetes Secrets (in profile namespaces).
##
{{<- define "kubeflow_pipelines.object_store.profile.generated_secret_key_key" ->}}
{{< .Values.deploykf_core.deploykf_profiles_generator.profileDefaults.tools.kubeflowPipelines.objectStoreAuth.existingSecretSecretKeyKey >}}
{{<- end ->}}

##
## A template for a MinIO policy JSON that grants bucket read/write access for a specific PROFILE.
## - USAGE: `$policy_json := tmpl.Exec "kubeflow_pipelines.object_store.profile.minio_policy" (dict "profile_name" "my_profile" "bucket_name" "my_bucket")`
##
{{<- define "kubeflow_pipelines.object_store.profile.minio_policy" ->}}
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::{{< .bucket_name >}}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::{{< .bucket_name >}}/artifacts/{{< .profile_name >}}/*",
        "arn:aws:s3:::{{< .bucket_name >}}/v2/artifacts/{{< .profile_name >}}/*"
      ]
    }
  ]
}
{{<- end ->}}

##
## A template for a MinIO policy YAML that grants bucket read/write access for a specific USER.
## - USAGE: `$policy_yaml := tmpl.Exec "kubeflow_pipelines.object_store.user.minio_policy" (dict "edit_profiles" $edit_profiles "view_profiles" $view_profiles "bucket_name" $bucket_name)`
##
{{<- define "kubeflow_pipelines.object_store.user.minio_policy" ->}}
{{<- $bucket_name := .bucket_name >}}
{{<- $edit_profiles := .edit_profiles >}}
{{<- $view_profiles := .view_profiles >}}
Version: "2012-10-17"
Statement:
  - Effect: Allow
    Action:
      - s3:GetBucketLocation
      - s3:ListBucket
    Resource:
      - arn:aws:s3:::{{< $bucket_name >}}
  {{<- range $profile_name := $edit_profiles >}}
  - Effect: Allow
    Action:
      - s3:GetObject
      - s3:PutObject
      - s3:DeleteObject
    Resource:
      - arn:aws:s3:::{{< $bucket_name >}}/artifacts/{{< $profile_name >}}/*
      - arn:aws:s3:::{{< $bucket_name >}}/v2/artifacts/{{< $profile_name >}}/*
  {{<- end >}}
  {{< range $profile_name := $view_profiles >}}
  - Effect: Allow
    Action:
      - s3:GetObject
    Resource:
      - arn:aws:s3:::{{< $bucket_name >}}/artifacts/{{< $profile_name >}}/*
      - arn:aws:s3:::{{< $bucket_name >}}/v2/artifacts/{{< $profile_name >}}/*
  {{<- end >}}
{{<- end ->}}