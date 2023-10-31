# deployKF ArgoCD Plugin

The deployKF ArgoCD plugin allows using deployKF without storing the rendered manifests in a git repository.

## Install Plugin - New ArgoCD

We provide manifests to install ArgoCD, with the deployKF plugin already installed, under the [`./argocd-install/`](./argocd-install) directory.

The [`./install_argocd.sh`](./install_argocd.sh) script will install ArgoCD from these manifests:

```bash
# clone the deploykf repository (at the 'main' branch)
git clone -b main https://github.com/deployKF/deployKF.git ./deploykf

# change to the argocd-plugin directory
cd ./deploykf/argocd-plugin

# install argocd (with the deploykf plugin)
# WARNING: this will install into your current kubectl context
./install_argocd.sh
```

> __WARNING:__ 
> 
> If you already have ArgoCD installed, take extreme caution with the `./install_argocd.sh` script.
> If you are not certain that our manifests are compatible with your existing ArgoCD installation, you should use the manual plugin install method.

## Install Plugin - Existing ArgoCD

To install the deployKF plugin on an existing ArgoCD deployment, you must do the following (in your `argocd` Namespace):

1. Create a `ConfigMap` named `argocd-deploykf-plugin` with [`./deploykf-plugin/plugin.yaml`](./argocd-install/deploykf-plugin/plugin.yaml) as a key named `plugin.yaml`.
2. Create a `PersistentVolumeClaim` named `argocd-deploykf-plugin-assets` like [`./deploykf-plugin/assets-pvc.yaml`](./argocd-install/deploykf-plugin/assets-pvc.yaml).
3. Patch the `argocd-repo-server` Deployment with the [`./deploykf-plugin/repo-server-patch.yaml`](./argocd-install/deploykf-plugin/repo-server-patch.yaml) patch.

The [`./patch_argocd.sh`](./patch_argocd.sh) script will perform these steps for you:

```bash
# clone the deploykf repository (at the 'main' branch)
git clone -b main https://github.com/deployKF/deployKF.git ./deploykf

# change to the argocd-plugin directory
cd ./deploykf/argocd-plugin

# patch argocd (with the deploykf plugin)
# WARNING: this will apply into your current kubectl context
./patch_argocd.sh
```

> __WARNING:__ 
> 
> Review the `./patch_argocd.sh` script to ensure it is suitable for your environment before running it.

## Plugin Usage

The primary use of the plugin is to provision a deployKF "app-of-apps" without storing the rendered manifests in a git repository.

### Plugin Parameters

The "deploykf" plugin has the following parameters:

| Parameter        | Type   | Description                                                                                                     |
|------------------|--------|-----------------------------------------------------------------------------------------------------------------|
| `source_version` | string | the '--source-version' to use with with the 'deploykf generate' command (mutually exclusive with `source_path`) |
| `source_path`    | string | the '--source-path' to use with the 'deploykf generate' command (mutually exclusive with `source_version`)      |
| `values_files`   | array  | a list of paths (under the configured repo path) of '--values' files to use with 'deploykf generate'            |
| `values`         | string | a string containing the contents of a '--values' file to use with 'deploykf generate'                           |

### Example

Here is an example ArgoCD Application which provisions an "app-of-apps" using the plugin:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: deploykf-app-of-apps
  namespace: argocd
  labels:
    app.kubernetes.io/name: deploykf-app-of-apps
    app.kubernetes.io/part-of: deploykf
spec:
  project: "default"
  source:
    ## source git repo configuration
    ##  - we use the 'deploykf/deploykf' repo so we can read its 'sample-values.yaml'
    ##    file, but you may use any repo (even one with no files)
    ##
    repoURL: "https://github.com/deployKF/deployKF.git"
    targetRevision: "v0.1.3" # <-- replace with a deployKF repo tag!
    path: "."

    ## plugin configuration
    ##
    plugin:
      name: "deploykf"
      parameters:

        ## the deployKF generator version
        ##  - available versions: https://github.com/deployKF/deployKF/releases
        ##
        - name: "source_version"
          string: "0.1.3" # <-- replace with a deployKF generator version!

        ## paths to values files within the `repoURL` repository
        ##  - the values in these files are merged, with later files taking precedence
        ##  - we strongly recommend using 'sample-values.yaml' as the base of your values
        ##    so you can easily upgrade to newer versions of deployKF
        ##
        - name: "values_files"
          array:
            - "./sample-values.yaml"

        ## a string containing the contents of a values file
        ##  - this parameter allows defining values without needing to create a file in the repo
        ##  - these values are merged with higher precedence than those defined in `values_files`
        ##
        - name: "values"
          string: |
            ##
            ## This demonstrates how you might structure overrides for the 'sample-values.yaml' file.
            ## For a more comprehensive example, see the 'sample-values-overrides.yaml' in the main repo.
            ##
            ## Notes:
            ##  - YAML maps are RECURSIVELY merged across values files
            ##  - YAML lists are REPLACED in their entirety across values files
            ##  - Do NOT include empty/null sections, as this will remove ALL values from that section.
            ##    To include a section without overriding any values, set it to an empty map: `{}`
            ##

            ## --------------------------------------------------------------------------------
            ##                              deploykf-dependencies
            ## --------------------------------------------------------------------------------
            deploykf_dependencies:

              ## --------------------------------------
              ##             cert-manager
              ## --------------------------------------
              cert_manager:
                {} # <-- REMOVE THIS, IF YOU INCLUDE VALUES UNDER THIS SECTION!

              ## --------------------------------------
              ##                 istio
              ## --------------------------------------
              istio:
                {} # <-- REMOVE THIS, IF YOU INCLUDE VALUES UNDER THIS SECTION!

              ## --------------------------------------
              ##                kyverno
              ## --------------------------------------
              kyverno:
                {} # <-- REMOVE THIS, IF YOU INCLUDE VALUES UNDER THIS SECTION!

            ## --------------------------------------------------------------------------------
            ##                                  deploykf-core
            ## --------------------------------------------------------------------------------
            deploykf_core:

              ## --------------------------------------
              ##             deploykf-auth
              ## --------------------------------------
              deploykf_auth:
                {} # <-- REMOVE THIS, IF YOU INCLUDE VALUES UNDER THIS SECTION!

              ## --------------------------------------
              ##        deploykf-istio-gateway
              ## --------------------------------------
              deploykf_istio_gateway:
                {} # <-- REMOVE THIS, IF YOU INCLUDE VALUES UNDER THIS SECTION!

              ## --------------------------------------
              ##      deploykf-profiles-generator
              ## --------------------------------------
              deploykf_profiles_generator:
                {} # <-- REMOVE THIS, IF YOU INCLUDE VALUES UNDER THIS SECTION!

            ## --------------------------------------------------------------------------------
            ##                                   deploykf-opt
            ## --------------------------------------------------------------------------------
            deploykf_opt:

              ## --------------------------------------
              ##            deploykf-minio
              ## --------------------------------------
              deploykf_minio:
                {} # <-- REMOVE THIS, IF YOU INCLUDE VALUES UNDER THIS SECTION!

              ## --------------------------------------
              ##            deploykf-mysql
              ## --------------------------------------
              deploykf_mysql:
                {} # <-- REMOVE THIS, IF YOU INCLUDE VALUES UNDER THIS SECTION!

            ## --------------------------------------------------------------------------------
            ##                                  kubeflow-tools
            ## --------------------------------------------------------------------------------
            kubeflow_tools:

              ## --------------------------------------
              ##                 katib
              ## --------------------------------------
              katib:
                {} # <-- REMOVE THIS, IF YOU INCLUDE VALUES UNDER THIS SECTION!

              ## --------------------------------------
              ##               notebooks
              ## --------------------------------------
              notebooks:
                {} # <-- REMOVE THIS, IF YOU INCLUDE VALUES UNDER THIS SECTION!

              ## --------------------------------------
              ##               pipelines
              ## --------------------------------------
              pipelines:
                {} # <-- REMOVE THIS, IF YOU INCLUDE VALUES UNDER THIS SECTION!

  destination:
    server: "https://kubernetes.default.svc"
    namespace: "argocd"
```

For example, to apply the example app-of-apps [`./example-app-of-apps/app-of-apps.yaml`](./example-app-of-apps/app-of-apps.yaml):

```bash
# clone the deploykf repository (at the 'main' branch)
git clone -b main https://github.com/deployKF/deployKF.git ./deploykf

# change to the argocd-plugin directory
cd ./deploykf/argocd-plugin

# apply the example app-of-apps
ARGOCD_NAMESPACE="argocd"
kubectl apply -f ./example-app-of-apps/app-of-apps.yaml --namespace "$ARGOCD_NAMESPACE"
```
