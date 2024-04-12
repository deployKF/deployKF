# deployKF ArgoCD Plugin

The deployKF ArgoCD plugin allows using deployKF without storing the rendered manifests in a git repository.

## Installation

### New ArgoCD

If you don't already have ArgoCD on your cluster, you may use the [`./install_argocd.sh`](./install_argocd.sh) script.

For example, you might run the following commands:

```bash
# clone the deploykf repo
#  NOTE: we use 'main', as the latest plugin version always lives there
git clone -b main https://github.com/deployKF/deployKF.git ./deploykf

# ensure the script is executable
chmod +x ./deploykf/argocd-plugin/install_argocd.sh

# run the INSTALL script
#  WARNING: this will install into your current kubectl context
bash ./deploykf/argocd-plugin/install_argocd.sh
```

> __WARNING:__ 
> 
> If you already have ArgoCD installed, DO NOT use the `./install_argocd.sh` script.

### Existing ArgoCD - Helm

If you already have an ArgoCD that was [installed with Helm](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd), you will need to update your Helm values.

See: [`./argocd-helm/values.yaml`](./argocd-helm/values.yaml)

> __WARNING:__ 
> 
> Helm list-type values are NOT merged.
> <br>
> If a list is redefined, the new list will replace the old one in full.
> 
> This means that if you already set some of the values we use, you will need to merge them manually.

### Existing ArgoCD - Kustomize

If you already have an ArgoCD that was [installed with Kustomize](https://argo-cd.readthedocs.io/en/stable/getting_started/), you may use the [`./patch_argocd.sh`](./patch_argocd.sh) script.

For example, you might run the following commands:

```bash
# clone the deploykf repo
#  NOTE: we use 'main', as the latest plugin version always lives there
git clone -b main https://github.com/deployKF/deployKF.git ./deploykf

# ensure the script is executable
chmod +x ./deploykf/argocd-plugin/install_argocd.sh

# run the PATCH script
#  WARNING: this will apply into your current kubectl context
bash ./deploykf/argocd-plugin/patch_argocd.sh
```

> __WARNING:__ 
> 
> Review the `./patch_argocd.sh` script to ensure it is suitable for your environment before running it.
>
> The script does the following:
> 
> 1. Creates a `ConfigMap` named `argocd-deploykf-plugin` with [`./deploykf-plugin/plugin.yaml`](./argocd-install/deploykf-plugin/plugin.yaml) as a key named `plugin.yaml`.
> 2. Creates a `PersistentVolumeClaim` named `argocd-deploykf-plugin-assets` with [`./deploykf-plugin/assets-pvc.yaml`](./argocd-install/deploykf-plugin/assets-pvc.yaml).
> 3. Patches the `argocd-repo-server` Deployment with the [`./deploykf-plugin/repo-server-patch.yaml`](./argocd-install/deploykf-plugin/repo-server-patch.yaml) patch.

---

<br>

## Plugin Usage

The primary use of the plugin is to provision a deployKF "app-of-apps" without storing the rendered manifests in a git repository.

### Plugin Parameters

The "deploykf" plugin has the following parameters:

| Parameter        | Type   | Description                                                                                                     |
|------------------|--------|-----------------------------------------------------------------------------------------------------------------|
| `source_version` | string | the '--source-version' to use with with the 'deploykf generate' command<br>(mutually exclusive with `source_path`) |
| `source_path`    | string | the '--source-path' to use with the 'deploykf generate' command<br>(mutually exclusive with `source_version`)      |
| `values_files`   | array  | a list of paths (under the configured repo path) of '--values' files to use with 'deploykf generate'            |
| `values`         | string | a string containing the contents of a '--values' file to use with 'deploykf generate'                           |

### Example Application

See the [`./example-app-of-apps/app-of-apps.yaml`](./example-app-of-apps/app-of-apps.yaml) file for an example of using the plugin.

To apply the example app-of-apps, you might run the following commands:

```bash
# clone the deploykf repo
git clone -b main https://github.com/deployKF/deployKF.git ./deploykf

# apply the example app-of-apps
ARGOCD_NAMESPACE="argocd"
kubectl apply -f ./deploykf/argocd-plugin/example-app-of-apps/app-of-apps.yaml \
  --namespace "$ARGOCD_NAMESPACE"
```
