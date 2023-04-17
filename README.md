<h1 align="center">deployKF</h1>

<div align="center">
  <b>Deploy the Machine Learning Toolkit for Kubernetes</b>
</div>

<br>

<div align="center">
  <a href="https://www.deploykf.org/" target="_blank" rel="noopener">
    <img src="https://www.deploykf.org/assets/images/logo.svg" width="100">
  </a>
</div>

<br>

<p align="center">
  <b>deployKF</b> effortlessly integrates <a href="https://www.kubeflow.org/" target="_blank" rel="noopener">Kubeflow</a> and leading MLOps tools on <a href="https://kubernetes.io/" target="_blank" rel="noopener">Kubernetes</a>, compose your open ML platform today!
</p>

<div align="center">
  <a href="https://github.com/deployKF/deployKF/fork">
    <img alt="Contributors" src="https://img.shields.io/github/forks/deployKF/deployKF?style=flat-square&color=28a745">
  </a>
  <a href="https://github.com/deployKF/deployKF/graphs/contributors">
    <img alt="Contributors" src="https://img.shields.io/github/contributors/deployKF/deployKF?style=flat-square&color=28a745">
  </a>
  <a href="https://github.com/deployKF/deployKF/blob/master/LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/deployKF/deployKF?style=flat-square&color=28a745">
  </a>
  <a href="https://github.com/deployKF/deployKF/releases">
    <img alt="Latest Release" src="https://img.shields.io/github/v/release/deployKF/deployKF?style=flat-square&color=6f42c1&label=latest%20release">
  </a>
  <br>
  <a href="https://github.com/deployKF/deployKF/stargazers">
    <img alt="GitHub Stars" src="https://img.shields.io/github/stars/deployKF/deployKF?style=for-the-badge&color=ffcb2f&label=Support%20with%20%E2%AD%90%20on%20GitHub">
  </a>
  <br>
  <sub><sub>Crafted with ❤️ by the developers of Kubeflow.</sub></sub>
</div>

## Usage

### Prerequisites

- the `deploykf` cli tool, [found in the `deployKF/cli` repo](https://github.com/deployKF/cli)
- a Kubernetes cluster with [ArgoCD](https://argo-cd.readthedocs.io/en/stable/getting_started/) installed
- a private git repo in which to store your generated manifests

### Quickstart

Get started with deployKF by following these steps:

1. clone your private manifest repo, and make the following changes:
    1. create an initial `custom-values.yaml` file ~~with the interactive `deploykf init-values --source-version "v0.1.0-alpha.0"` command~~ _(not yet implemented)_
        - _TIP: for now, use the [`values.yaml`](values.yaml) and [`generator/default_values.yaml`](generator/default_values.yaml) files in this repo as a starting point_
    2. make further customizations to your `custom-values.yaml` file
        - _TIP: make sure you set `repo.url` and `repo.branch` to the correct values for your git repo_
    3. generate your manifests using the `deploykf generate` command:
        - `deploykf generate --source-version "v0.1.0-alpha.0" --values ./custom-values.yaml --output-dir ./GENERATOR_OUTPUT`
    4. commit the generated files (and any other files you may want) to your private git repo: 
        - `git add GENERATOR_OUTPUT`
        - `git commit -m "my commit message"`
        - `git push`
2. manually apply the generated ArgoCD ["app of apps"](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern) to your Kubernetes cluster:
    - `kubectl apply --filename GENERATOR_OUTPUT/app-of-apps.yaml`
3. go to your ArgoCD web interface, and sync the ArgoCD applications:
    1. _WARNING: you __MUST SYNC THE APPLICATIONS IN THE ORDER LISTED BELOW__, as some applications depend on others_
    2. `deploykf-app-of-apps`
    3. __deploykf-dependencies__ _(label: `app.kubernetes.io/component: deploykf-dependencies`)_
        1. `dkf-dep--kyverno`
        2. `dkf-dep--cert-manager`
            - _WARNING: first sync may fail as trust-manager depends on cert-manager, so once cert-manager pods are up, terminate the first hung sync (under "SYNC STATUS"), and sync again_
        3. `dkf-dep--sealed-secrets`
        4. `dkf-dep--istio`
            - _WARNING: first sync may fail, so wait and sync again_
        5. `dkf-dep--knative--knative-eventing`
        6. `dkf-dep--knative--knative-serving`
    4. __deploykf-core__ _(label: `app.kubernetes.io/component: deploykf-core`)_
        1. `dkf-core--kubeflow-istio-gateway`
        2. `dkf-core--kubeflow-auth`
        3. `dkf-core--kubeflow-dashboard`
        4. `dkf-core--minio`
        5. `dkf-core--mysql`
        6. `dkf-core--argo-workflows`
        7. `dkf-core--kubeflow-profiles-generator`
            - _WARNING: first sync may fail as profile namespaces will not immediately be created, so wait for those namespace to be created, and sync again_
    5. __kubeflow-tools__ _(label: `app.kubernetes.io/component: kubeflow-tools`)_
        1. `kf-tools--pipelines`
        2. `kf-tools--poddefaults-webhook`
        3. `kf-tools--notebooks--notebook-controller` 
        4. `kf-tools--notebooks--jupyter-web-app`
        5. `kf-tools--tensorboards--tensorboard-controller`
        6. `kf-tools--tensorboards--tensorboards-web-app`
        7. `kf-tools--volumes--volumes-web-app`
        8. `kf-tools--training-operator`
        9. `kf-tools--katib`
    6. __kubeflow-contrib__ _(label: `app.kubernetes.io/component: kubeflow-contrib`)_
        1. `kf-contrib--kserve--kserve`
        2. `kf-contrib--kserve--models-web-app`
4. access the Kubeflow UI through the Istio Gateway Service:
    1. add the following lines to your `/etc/hosts` file:
        - `127.0.0.1 kubeflow.example.com` 
        - `127.0.0.1 argo-server.kubeflow.example.com` 
        - `127.0.0.1 minio-api.kubeflow.example.com` 
        - `127.0.0.1 minio-console.kubeflow.example.com`
    2. port forward the service using `kubectl` (default: `Service/kubeflow-gateway` in `Namespace/kubeflow-istio-gateway`):
        - `kubectl port-forward --namespace kubeflow-istio-gateway Service/kubeflow-gateway 8080:8080 8443:8443`
    3. open the Kubeflow UI in your browser:
        - https://kubeflow.example.com:8443/
    4. use the following default credentials (if you have not changed them):
        - username: `admin@example.com`
        - password: `admin`
5. whenever you want to update your Kubeflow deployment, you can repeat steps 1-4, to update your existing manifests
    - _TIP: any manual changes made in the `--output-dir` will be overwritten by the `deploykf generate` command, so please only make changes in your `--values` files_
       - if you have changes that are not yet possible to make with a `--values` file, please [raise an issue](https://github.com/deployKF/deployKF/issues)

## Troubleshooting

### ERROR: pods fail with "too many open files"

This error has been [discussed in upstream kubeflow repos](https://github.com/kubeflow/manifests/issues/2087), to resolve it you will need to increase your system's open/watched file limits.

On linux, you may need to increase the `fs.inotify.max_user_*` sysctl values, here are some values which users have reported to work:

1. Modify `/etc/sysctl.conf` to include the following lines:
    - `fs.inotify.max_user_instances = 1280`
    - `fs.inotify.max_user_watches = 655360`
2. Reload sysctl configs by running `sudo sysctl -p`