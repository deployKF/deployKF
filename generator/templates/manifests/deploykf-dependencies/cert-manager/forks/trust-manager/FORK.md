# About this Fork

This is a fork of the upstream [trust-manager](https://github.com/cert-manager/trust-manager/tree/main/deploy/charts/trust-manager) Helm chart for use in deployKF.

__The changes made in this fork are:__

- the chart version has been suffixed with `-deploykf`, to avoid confusion with the upstream chart
- added the `app.deploymentAnnotations` value (used to set `argocd.argoproj.io/sync-wave` to resolve race conditions on sync)
- added the `app.certificateAnnotations` value (used to set `argocd.argoproj.io/sync-wave` to resolve race conditions on sync)
- added the `app.webhook.validatingWebhookConfigurationAnnotations` value (used to work around Azure AKS Admissions Enforcer)

To aid in the maintenance of this fork, all places where changes have been made are wrapped as follows:

```yaml
#################### BEGIN CHANGE ####################
...
##################### END CHANGE #####################
```