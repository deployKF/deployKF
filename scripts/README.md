# deployKF Reference Scripts

This directory contains helpful scripts for working with deployKF.

## [`sync_argocd_apps.sh`](./sync_argocd_apps.sh)

This script automatically syncs the ArgoCD applications that make up deployKF.

### Requirements:

- Bash `4.4` or later _(macOS has `3.2` by default, update with `brew install bash`)_
- The `kubectl` CLI is installed ([install guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/))
- The `argocd` CLI is installed ([install guide](https://argo-cd.readthedocs.io/en/stable/cli_installation/))
- The `jq` CLI is installed ([install guide](https://stedolan.github.io/jq/download/))
- A deployKF "app of apps" has been applied to the cluster ([example for plugin mode](../argocd-plugin/README.md#plugin-usage))
- The deployKF version being used is `0.1.2` or later ([release notes](https://www.deploykf.org/releases/changelog-deploykf/))

### Behavior:

By default, the script will:

- Use `kubectl` port-forwarding to connect to the ArgoCD API server.
- Assume ArgoCD is installed to the `argocd` Namespace.
- Assume the ArgoCD `admin` password can be found in `Secret/argocd-initial-admin-secret`.
- Prompt for confirmation before pruning (deleting) resources during a sync.

### Usage:

To run the script with the default settings:

```bash
# clone the deploykf repo
# NOTE: we use 'main', as the latest script always lives there
git clone -b main https://github.com/deployKF/deployKF.git ./deploykf

# ensure the script is executable
chmod +x ./deploykf/scripts/sync_argocd_apps.sh

# run the script
bash ./deploykf/scripts/sync_argocd_apps.sh
```

> __NOTE:__
>
> - The script can take around 5-10 minutes to run on first install.
> - If the script fails or is interrupted, you can safely re-run it, and it will pick up where it left off.
> - There are a number of configuration variables at the top of the script which change the default behavior.

---

## [`update_istio_sidecars.sh`](./update_istio_sidecars.sh)

This script restarts Pods with Istio sidecar versions that do not match the current Istio version.

### Requirements:

- Bash `4.4` or later _(macOS has `3.2` by default, update with `brew install bash`)_
- The `istioctl` CLI is installed ([install guide](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/))
- The `kubectl` CLI is installed ([install guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/))
- The `jq` CLI is installed ([install guide](https://stedolan.github.io/jq/download/))

### Behavior:

By default, the script will:

- Use `istioctl` to get the current Istio version and sidecar versions.
- Prompt for confirmation before restarting Pods.
- For each Pod with an outdated sidecar, it will:
  - Use `kubectl` to get the `metadata.ownerReferences` for the Pod.
  - Use `kubectl rollout restart` to restart the owner of the Pod (e.g. Deployment, StatefulSet, etc.).

### Usage:

To run the script with the default settings:

```bash
# clone the deploykf repo
# NOTE: we use 'main', as the latest script always lives there
git clone -b main https://github.com/deployKF/deployKF.git ./deploykf

# ensure the script is executable
chmod +x ./deploykf/scripts/update_istio_sidecars.sh

# run the script
bash ./deploykf/scripts/update_istio_sidecars.sh
```

> __WARNING:__
>
> - This script will restart Pods in your cluster (if you confirm when prompted).
> - It is recommended to run this script during a maintenance window or when you can tolerate downtime.
> - When restarting Notebook Pods (which show as StatefulSets), all in-progress and unsaved work will be lost!
> - All out-of-date Pods are restarted at the SAME TIME, which may not be suitable for large clusters.
