# deployKF Reference Scripts

This directory contains helpful scripts for working with deployKF.

## [`sync_argocd_apps.sh`](./sync_argocd_apps.sh)

This script automatically syncs the ArgoCD applications that make up deployKF.

### Requirements:

- Bash `4.2` or later _(macOS has `3.2` by default, update with `brew install bash`)_
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
- Prompt for confirmation before pruning (deleting) resources during a sync (defaults to `no` after 30 seconds).

### Usage:

To run the script with the default settings:

```bash
# clone the deploykf repository (at the 'main' branch)
git clone -b main https://github.com/deployKF/deployKF.git ./deploykf

# change to the argocd-plugin directory
cd ./deploykf/scripts

# ensure the script is executable
chmod +x ./sync_argocd_apps.sh

# sync all deployKF ArgoCD applications
./sync_argocd_apps.sh
```

> __NOTE:__
>
> - The script can take around 5-10 minutes to run on first install.
> - If the script fails or is interrupted, you can safely re-run it, and it will pick up where it left off.
> - There are a number of configuration variables at the top of the script which change the default behavior.