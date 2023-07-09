<h1 align="center">deployKF</h1>

<div align="center">
  <b>Deploy the Machine Learning Toolkit for Kubernetes</b>
</div>

<br>

<div align="center">
  <a href="https://www.deploykf.org/" target="_blank" rel="noopener">
    <img src="https://www.deploykf.org/assets/images/logo_1/logo.svg" width="100">
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

## About

### What is deployKF?

deployKF is the best way to build reliable ML Platforms on Kubernetes.

- deployKF supports the top [ML & Data tools](https://www.deploykf.org/reference/tools/) from both Kubeflow, and other projects
- deployKF has a Helm-like interface, with central [values (configs)](https://www.deploykf.org/reference/deploykf-values/) for configuring all aspects of the deployment (no need to edit Kubernetes YAML directly)
- deployKF does NOT install resources into your cluster, instead it generates [Argo CD Applications](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications) which you apply to your cluster and then [sync with the Argo CD UI](https://argo-cd.readthedocs.io/en/stable/getting_started/#syncing-via-ui)

### What tools does deployKF support?

deployKF currently supports MLOps tools from the Kubeflow ecosystem like [Kubeflow Pipelines](https://www.deploykf.org/reference/tools/#kubeflow-pipelines) and [Kubeflow Notebooks](https://www.deploykf.org/reference/tools/#kubeflow-notebooks), for the full list of current tools, please see the [supported tools page](https://www.deploykf.org/reference/tools/).

We are actively adding support for other popular tools such as [MLflow Model Registry](https://www.deploykf.org/reference/future-tools/#mlflow-model-registry), [Apache Airflow](https://www.deploykf.org/reference/future-tools/#apache-airflow), and [Feast](https://www.deploykf.org/reference/future-tools/#feast). 
For a more complete list of planned tools, please see the [future tools page](https://www.deploykf.org/reference/future-tools/).

### Who makes deployKF?

deployKF was originally created by [Mathew Wicks](https://www.linkedin.com/in/mathewwicks/) ([GitHub: @thesuperzapper](https://github.com/thesuperzapper)), a Kubeflow lead and maintainer of the popular [Apache Airflow Helm Chart](https://github.com/airflow-helm/charts).
However, deployKF is now a community-led project, and welcomes contributions from anyone who wants to help.

For commercial services related to deployKF, please see the [support page](https://www.deploykf.org/about/support/#commercial-support).

### Who uses deployKF?

deployKF is a new project, and we are still building our community.
If you are using deployKF, please consider adding your organization to our [list of adopters](ADOPTERS.md).

### What is the difference between Kubeflow and deployKF?

deployKF and Kubeflow are two different projects, but they are related:
      
- deployKF is a tool for deploying Kubeflow and other MLOps tools on Kubernetes as a cohesive platform.
- Kubeflow is a project that develops many MLOps tools, including Kubeflow Pipelines, Kubeflow Notebooks, Katib, and more.

For more details, see our [comparison between Kubeflow and deployKF](https://www.deploykf.org/about/kubeflow-vs-deploykf/).

### How can I get involved with deployKF?

The deployKF project is a welcoming community of contributors and users. 
We encourage participation from anyone who shares our mission of making it easy to build open ML Platforms on Kubernetes.

For more details, see our [community page](https://www.deploykf.org/about/community/).

## Usage

For full details on how to get started with deployKF, please see the [getting started guide](https://www.deploykf.org/guides/getting-started/).

### Prerequisites

- the `deploykf` cli tool, [found in the `deployKF/cli` repo](https://github.com/deployKF/cli)
- a Kubernetes cluster with [ArgoCD](https://argo-cd.readthedocs.io/en/stable/getting_started/) installed
- a private git repo in which to store your generated manifests

### Quickstart

Get started with deployKF by following these steps:

1. prepare your private git repo:
    1. create an initial `custom-values.yaml` file:
        - _TIP: start by copying the [`sample-values.yaml`](sample-values.yaml) file, which includes a reasonable set of default values with all tools enabled_
        - _TIP: refer to [`generator/default_values.yaml`](generator/default_values.yaml) for the full list of available values_
        - _TIP: set `argocd.source.repo.url` and `argocd.source.repo.revision` to the correct values for your git repo_
        - _TIP: change which of the [supported tools](https://www.deploykf.org/reference/tools/) are deployed by changing their `enabled` values_
    2. generate your manifests:
        - `deploykf generate --source-version "X.X.X" --values ./custom-values.yaml --output-dir ./GENERATOR_OUTPUT`
        - _TIP: you may specify `--values` multiple times, they will be merged with later ones taking precedence_
        - _TIP: any manual changes made in the `--output-dir` will be overwritten by the `deploykf generate` command, so please only make changes in your `--values` files_
           - if you find something you need to change that is not yet possible with values please [raise an issue](https://github.com/deployKF/deployKF/issues)
    3. commit the generated files to your private git repo: 
        - `git add GENERATOR_OUTPUT`
        - `git commit -m "my commit message"`
        - `git push`
2. manually apply the generated ArgoCD ["app of apps"](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern) to your Kubernetes cluster:
    - `kubectl apply --filename GENERATOR_OUTPUT/app-of-apps.yaml`
3. go to your ArgoCD web interface, and sync the ArgoCD applications:
    1. __WARNING:__ you should sync each "group" of applications in the following order, as they depend on each other
    2. __app-of-apps__
        1. `deploykf-app-of-apps`
    3. __deploykf-dependencies:__ 
        1. (group label: `app.kubernetes.io/component: deploykf-dependencies`)
        1. `dkf-dep--kyverno`
        2. `dkf-dep--cert-manager` (first sync will fail as trust-manager depends on cert-manager, so wait for cert-manager to be ready and sync again)
        3. `dkf-dep--istio`
    4. __deploykf-core:__ 
        1. (group label: `app.kubernetes.io/component: deploykf-core`)
        1. `dkf-core--deploykf-istio-gateway`
        2. `dkf-core--deploykf-auth`
        3. `dkf-core--deploykf-dashboard`
        4. `dkf-core--deploykf-profiles-generator` (first sync will fail while profile namespaces are created, so wait for those namespace to be created and sync again)
    5. __deploykf-opt:__ 
        1. (group label: `app.kubernetes.io/component: deploykf-opt`)
        1. `dkf-opt--deploykf-mysql`
        2. `dkf-opt--deploykf-minio`
    6. __deploykf-tools:__ 
        1. (group label: `app.kubernetes.io/component: deploykf-tools`)
        1. N/A
    7. __kubeflow-dependencies:__ 
        1. (group label: `app.kubernetes.io/component: kubeflow-dependencies`)
        1. `kf-dep--argo-workflows`
    8. __kubeflow-tools:__ 
        1. (group label: `app.kubernetes.io/component: kubeflow-tools`)
        1. `kf-tools--pipelines`
        2. `kf-tools--poddefaults-webhook`
        3. `kf-tools--notebooks--notebook-controller` 
        4. `kf-tools--notebooks--jupyter-web-app`
        5. `kf-tools--tensorboards--tensorboard-controller`
        6. `kf-tools--tensorboards--tensorboards-web-app`
        7. `kf-tools--volumes--volumes-web-app`
        8. `kf-tools--training-operator`
        9. `kf-tools--katib`
4. access the Kubeflow UI through the Istio Gateway Service with `kubectl` port-forwarding:
    1. add the following lines to your `/etc/hosts` file:
        - `127.0.0.1 deploykf.example.com` 
        - `127.0.0.1 argo-server.deploykf.example.com` 
        - `127.0.0.1 minio-api.deploykf.example.com` 
        - `127.0.0.1 minio-console.deploykf.example.com`
    2. port forward the service using `kubectl` (default: `Service/kubeflow-gateway` in `Namespace/deploykf-istio-gateway`):
        - `kubectl port-forward --namespace deploykf-istio-gateway Service/kubeflow-gateway 8080:8080 8443:8443`
    3. open the dashboard in your browser:
        - https://deploykf.example.com:8443/
    4. use one of the following default credentials (if you have not changed them):
        - super-admin:
            - username: `admin@example.com`
            - password: `admin`
        - user-1:
            - username: `user1@example.com`
            - password: `user1`
        - user-2:
            - username: `user2@example.com`
            - password: `user2`
5. whenever you want to change your deployKF, you can repeat steps 1 and 3, to update your existing manifests

## Troubleshooting

### ERROR: pods fail with "too many open files"

This error has been [discussed in upstream kubeflow repos](https://github.com/kubeflow/manifests/issues/2087), to resolve it you will need to increase your system's open/watched file limits.

On linux, you may need to increase the `fs.inotify.max_user_*` sysctl values, here are some values which users have reported to work:

1. Modify `/etc/sysctl.conf` to include the following lines:
    - `fs.inotify.max_user_instances = 1280`
    - `fs.inotify.max_user_watches = 655360`
2. Reload sysctl configs by running `sudo sysctl -p`