# deployKF ArgoCD Plugin

The deployKF ArgoCD plugin allows using deployKF without storing the rendered manifests in a git repository.

## Installation

Installing any ArgoCD plugin requires you to patch to the `argo-repo-server` Deployment.

### Full ArgoCD Installation

We provide manifests for ArgoCD with the deployKF plugin already installed under the [`./argocd-install/`](./argocd-install) directory.

The [`./install_argocd.sh`](./install_argocd.sh) script will install ArgoCD from these manifests.

> __WARNING:__ 
> 
> Be very careful about running `./install_argocd.sh` if you already have ArgoCD installed.
> If you have any non-default configurations (or want to use a different version of ArgoCD), you should use the manual plugin installation instructions.

### Manual Plugin Installation

To manually install the deployKF plugin on an existing ArgoCD deployment, you must do the following (in your `argocd` Namespace):

1. Create a `ConfigMap` named `argocd-deploykf-plugin` with [`./deploykf-plugin/plugin.yaml`](./argocd-install/deploykf-plugin/plugin.yaml) as a key.
2. Create a `PersistentVolumeClaim` named `argocd-deploykf-plugin-assets` like [`./deploykf-plugin/assets-pvc.yaml`](./argocd-install/deploykf-plugin/assets-pvc.yaml).
3. Patch the `argocd-repo-server` Deployment with the [`./deploykf-plugin/repo-server-patch.yaml`](./argocd-install/deploykf-plugin/repo-server-patch.yaml) patch.

The [`./patch_argocd.sh`](./patch_argocd.sh) script will perform these steps for you, but you should review the script before running it.

## Usage

To use deployKF with the plugin, you must create an ArgoCD Application for the "app-of-apps" which uses the plugin.

### Plugin Parameters

The "deploykf" plugin has the following parameters:

| Parameter        | Type   | Description                                                                                                     |
|------------------|--------|-----------------------------------------------------------------------------------------------------------------|
| `source_version` | string | the '--source-version' to use with with the 'deploykf generate' command (mutually exclusive with `source_path`) |
| `source_path`    | string | the '--source-path' to use with the 'deploykf generate' command (mutually exclusive with `source_version`)      |
| `values_files`   | array  | a list of paths (under the configured repo path) of '--values' files to use with 'deploykf generate'            |
| `values`         | string | a string containing the contents of a '--values' file to use with 'deploykf generate'                           |

### Example

Here is an example of an app-of-apps using the "deploykf" plugin:

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
    ## any valid git repository 
    ##  - note, this does NOT need to be the deployKF repository, we are only using it
    ##    to access the './sample-values.yaml' file for the `values_files` parameter
    ##
    repoURL: "https://github.com/deployKF/deployKF.git"
    targetRevision: "v0.1.1"
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
          string: "0.1.1"
          
        ## paths to values files within the `repoURL` repository
        ##
        - name: "values_files"
          array:
            - "./sample-values.yaml"
        
        ## a string containing the contents of a values file
        ##
        - name: "values"
          string: |
            ## --------------------------------------------------------------------------------
            ##
            ##                                  deploykf-core
            ##
            ## --------------------------------------------------------------------------------
            deploykf_core:
              
              ## --------------------------------------
              ##        deploykf-istio-gateway
              ## --------------------------------------
              deploykf_istio_gateway:
            
                ## istio gateway configs
                gateway:
                  hostname: deploykf.example.com

  destination:
    server: "https://kubernetes.default.svc"
    namespace: "argocd"
```

> __TIP:__ 
> 
> If not using `source_path` or `values_files`, the `spec.source.repoURL` may point to any valid git repository (even one with no files).
            