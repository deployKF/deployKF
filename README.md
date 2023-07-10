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
  <a href="https://www.deploykf.org/" target="_blank" rel="noopener"><b>deployKF</b></a> effortlessly integrates <a href="https://www.kubeflow.org/" target="_blank" rel="noopener">Kubeflow</a> and leading MLOps tools on <a href="https://kubernetes.io/" target="_blank" rel="noopener">Kubernetes</a>, compose your open ML platform today!
</p>

<div align="center">
  <a href="https://github.com/deployKF/deployKF/releases">
    <img alt="Downloads" src="https://img.shields.io/github/downloads/deployKF/deployKF/total?style=flat-square&color=28a745">
  </a>
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

- deployKF supports leading [MLOps & Data tools](https://www.deploykf.org/reference/tools/) from both Kubeflow, and other projects
- deployKF has a Helm-like interface, with [values](https://www.deploykf.org/reference/deploykf-values/) for configuring all aspects of the deployment (no need to edit Kubernetes YAML)
- deployKF does NOT install resources directly in your cluster, instead it generates [ArgoCD Applications](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications) to provide native GitOps support

### What tools does deployKF support?

deployKF currently supports MLOps tools from the Kubeflow ecosystem like [Kubeflow Pipelines](https://www.deploykf.org/reference/tools/#kubeflow-pipelines) and [Kubeflow Notebooks](https://www.deploykf.org/reference/tools/#kubeflow-notebooks), for the full list of current tools, please see the [supported tools page](https://www.deploykf.org/reference/tools/).

We are actively adding support for other popular tools such as [MLflow Model Registry](https://www.deploykf.org/reference/future-tools/#mlflow-model-registry), [Apache Airflow](https://www.deploykf.org/reference/future-tools/#apache-airflow), and [Feast](https://www.deploykf.org/reference/future-tools/#feast). 
For a more complete list of planned tools, please see the [future tools page](https://www.deploykf.org/reference/future-tools/).

### Who makes deployKF?

deployKF was originally created by [Mathew Wicks](https://www.linkedin.com/in/mathewwicks/) ([GitHub: @thesuperzapper](https://github.com/thesuperzapper)), a Kubeflow lead and maintainer of the popular [Apache Airflow Helm Chart](https://github.com/airflow-helm/charts).
However, deployKF is now a community-led project that welcomes contributions from anyone who wants to help.

For commercial services related to deployKF, please see the [support page](https://www.deploykf.org/about/support/#commercial-support).

### Who uses deployKF?

deployKF is a new project, and we are still building our community.
If you are using deployKF, please consider adding your organization to our [list of adopters](ADOPTERS.md).

### What is the difference between Kubeflow and deployKF?

Kubeflow and deployKF are two different but related projects:
      
- deployKF is a tool for deploying Kubeflow and other MLOps tools on Kubernetes as a cohesive platform.
- Kubeflow is a project that develops MLOps tools, including Kubeflow Pipelines, Kubeflow Notebooks, Katib, and more.

For more details, see our [comparison between Kubeflow and deployKF](https://www.deploykf.org/about/kubeflow-vs-deploykf/).

### How can I get involved with deployKF?

The deployKF project is a welcoming community of contributors and users. 
We encourage participation from anyone who shares our mission of making it easy to build open ML Platforms on Kubernetes.

For more details, see our [community page](https://www.deploykf.org/about/community/).

## Getting Started

For full details on how to get started with deployKF, please see the [getting started page](https://www.deploykf.org/guides/getting-started/).

### Requirements

- the `deploykf` cli tool, found in [the `deployKF/cli` repo](https://github.com/deployKF/cli)
- a Kubernetes cluster (__WARNING:__ we strongly recommend using a dedicated Kubernetes cluster for deployKF)
- ArgoCD is [deployed on your cluster](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- a private git repo (in which to store your generated manifests)

### Step 1: create your values file

deployKF is configured using YAML files containing configs named "values" which behave similarly to those in Helm.

deployKF has a very large number of configurable values (more than 1500), but you can start by defining a few important ones, and then grow your values file over time.

We recommend you start by copying the [`sample-values.yaml`](sample-values.yaml) file, which includes reasonable defaults that should work on any Kubernetes cluster,
the following values will need to be changed to match your environment:

- `argocd.source.repo.url`:
    - the URL of your manifest git repo
    - for example, if you are using a GitHub repo named 'deployKF/examples', you might set this value to `https://github.com/deployKF/examples` or `git@github.com:deployKF/examples.git`
    - _TIP: if you are using a private repo, you will need to [configure your ArgoCD with the appropriate credentials](https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories/)_
- `argocd.source.repo.revision`:
    - the git revision which contains your generated manifests
    - for example, if you are using the 'main' branch of your repo, you might set this value to "main"
- `argocd.source.repo.path`:
    - the path within your repo where the generated manifests are stored
    - for example, if you are using a folder named 'GENERATOR_OUTPUT' at the root of your repo, you might set this value to "./GENERATOR_OUTPUT/"

For information about other values, you can refer to the following resources:

- docstrings in [`generator/default_values.yaml`](generator/default_values.yaml), which contains defaults for all values
- the [values reference page](https://www.deploykf.org/reference/deploykf-values/), which contains a list of all values with links to their docstrings
- the "topics" section of the website, which has information about achieving specific goals, such as [using an external S3-compatible object store](https://www.deploykf.org/topics/production-usage/external-object-store/)

> __TIP:__ for a refresher on YAML syntax, we recommend [Learn YAML in Y minutes](https://learnxinyminutes.com/docs/yaml/) and [YAML Multiline Strings](https://yaml-multiline.info/)

### Step 2: generate your manifests

You must generate your manifests and commit them to a git repo before ArgoCD can deploy them to your cluster.

The `generate` command of the [`deploykf` CLI](https://github.com/deployKF/cli) creates a manifests folder for a specific version of deployKF and one or more values files:

```shell
deploykf generate \
    --source-version 0.1.0 \
    --values ./custom-values.yaml \
    --output-dir ./GENERATOR_OUTPUT
```

> __TIP:__ the `--source-version` can be any valid deployKF version, see the [changelog](https://www.deploykf.org/releases/changelog-deploykf/) for a list of versions

> __TIP:__ if you specify `--values` multiple times, they will be merged with later ones taking precedence (note, YAML lists are not merged, they are replaced in full)

> __TIP:__ any manual changes made in the `--output-dir` will be overwritten each time the `deploykf generate` command runs, so please only make changes in your `--values` files. 
> If you find yourself needing to make manual changes, this indicates we might need a new value, so please [raise an issue](https://github.com/deployKF/deployKF/issues) to help us improve the project!

> __TIP:__ after running `deploykf generate`, you will likely want to commit the changes to your repo:
> 
> ```shell
> # for example, to directly commit changes to the 'main' branch of your repo
> git add GENERATOR_OUTPUT
> git commit -m "my commit message"
> git push origin main
> ```

### Step 3: apply the manifests to your cluster

The only manifest you need to manually apply is the ArgoCD ["app of apps"](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern), which creates all the other ArgoCD applications.

The `app-of-apps.yaml` manifest is generated at the root of your `--output-dir` folder, so you can apply it with:

```shell
kubectl apply --filename GENERATOR_OUTPUT/app-of-apps.yaml
```

> __TIP:__ ensure you have ArgoCD [installed on your cluster](https://argo-cd.readthedocs.io/en/stable/getting_started/) before applying this manifest

### Step 4: access the ArgoCD web interface

If this is the first time you are using ArgoCD, you will need to retrieve the initial password for the `admin` user:

```shell
echo $(kubectl -n argocd get secret/argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
```

This `kubectl` command will port-forward the `argocd-server` Service to your local machine:

```shell
kubectl port-forward --namespace "argocd" svc/argocd-server 8090:https
```

You should now see the ArgoCD interface at https://localhost:8090, where you can log in with the `admin` user and the password you retrieved in the previous step.

### Step 5: sync the deployKF ArgoCD applications

You can now sync the ArgoCD applications which make up deployKF.

> __WARNING:__ you must sync each "group" of applications in the following order, as they depend on each other

1. __app-of-apps__:
    - APP NAME: `deploykf-app-of-apps`
2. __deploykf-dependencies:__
    - GROUP LABEL: `app.kubernetes.io/component: deploykf-dependencies`
    - APP NAMES:
       - `dkf-dep--cert-manager` 
           - _TIP: the first sync will fail as trust-manager depends on cert-manager, so wait for cert-manager to be ready and sync again_
       - `dkf-dep--istio`
       - `dkf-dep--kyverno`
3. __deploykf-core:__
    - GROUP LABEL: `app.kubernetes.io/component: deploykf-core`
    - APP NAMES:
       - `dkf-core--deploykf-auth`
       - `dkf-core--deploykf-dashboard`
       - `dkf-core--deploykf-istio-gateway`
       - `dkf-core--deploykf-profiles-generator` 
           - _TIP: the first sync will fail while profile namespaces are created, so wait for those namespace to be created and sync again_
4. __deploykf-opt:__ 
    - GROUP LABEL: `app.kubernetes.io/component: deploykf-opt`
    - APP NAMES:
       - `dkf-opt--deploykf-minio`
       - `dkf-opt--deploykf-mysql`
5. __deploykf-tools:__ 
    - GROUP LABEL: `app.kubernetes.io/component: deploykf-tools`
    - APP NAMES:
       - N/A
6. __kubeflow-dependencies:__ 
    - GROUP LABEL: `app.kubernetes.io/component: kubeflow-dependencies`
    - APP NAMES:
       - `kf-dep--argo-workflows`
7. __kubeflow-tools:__ 
    - GROUP LABEL: `app.kubernetes.io/component: kubeflow-tools`
    - APP NAMES:
       - `kf-tools--katib`
       - `kf-tools--notebooks--jupyter-web-app`
       - `kf-tools--notebooks--notebook-controller` 
       - `kf-tools--pipelines`
       - `kf-tools--poddefaults-webhook`
       - `kf-tools--tensorboards--tensorboard-controller`
       - `kf-tools--tensorboards--tensorboards-web-app`
       - `kf-tools--training-operator`
       - `kf-tools--volumes--volumes-web-app`

> __TIP:__ you may also sync the applications with the [`argocd` CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/), but at first, we recommend syncing with the web interface, so you can debug any issues:
> 
> ```shell
> # expose ArgoCD API server
> kubectl port-forward svc/argocd-server -n argocd 8090:https
> 
> # get the admin password (if you have not changed it)
> argocd "admin" initial-password -n argocd
> 
> # log in to ArgoCD
> ARGOCD_PASSWORD="<YOUR_PASSWORD_HERE>"
> argocd login localhost:8090 --username "admin" --password "$ARGOCD_PASSWORD" --insecure
> 
> # sync the apps
> argocd app sync "deploykf-app-of-apps"
> argocd app sync -l "app.kubernetes.io/component=deploykf-dependencies"
> argocd app sync -l "app.kubernetes.io/component=deploykf-core"
> argocd app sync -l "app.kubernetes.io/component=deploykf-opt"
> argocd app sync -l "app.kubernetes.io/component=deploykf-tools"
> argocd app sync -l "app.kubernetes.io/component=kubeflow-dependencies"
> argocd app sync -l "app.kubernetes.io/component=kubeflow-tools"
> ```

### Step 6: access the deployKF web interface

If you have not configured a public Service for your `deploykf-istio-gateway`, you may access the deployKF web interface with `kubectl` port-forwarding.

First, you will need to add some lines to your `/etc/hosts` file (this is needed because Istio uses the `Host` header to route requests to the correct VirtualService).

For example, if you have set the `deploykf_core.deploykf_istio_gateway.gateway.hostname` value to `"deploykf.example.com"`, you would add the following lines:

```shell
127.0.0.1 deploykf.example.com
127.0.0.1 argo-server.deploykf.example.com
127.0.0.1 minio-api.deploykf.example.com
127.0.0.1 minio-console.deploykf.example.com
```

This `kubectl` command will port-forward the `deploykf-gateway` Service to your local machine:

```shell
kubectl port-forward --namespace "deploykf-istio-gateway" svc/deploykf-gateway 8080:http 8443:https
```

You should now see the deployKF dashboard at https://deploykf.example.com:8443/, where you can use one of the following credentials (if you have not changed them):

- Super Admin:
    - username: `admin@example.com`
    - password: `admin`
- User 1:
    - username: `user1@example.com`
    - password: `user1`
- User 2:
    - username: `user2@example.com`
    - password: `user2`

## Troubleshooting

### ERROR: pods fail with "too many open files"

This error has been [discussed in the upstream kubeflow repo](https://github.com/kubeflow/manifests/issues/2087), to resolve it you will need to increase your system's open/watched file limits.

On linux, you may need to increase the `fs.inotify.max_user_*` sysctl values, here are some values which users have reported to work:

1. Modify `/etc/sysctl.conf` to include the following lines:
    - `fs.inotify.max_user_instances = 1280`
    - `fs.inotify.max_user_watches = 655360`
2. Reload sysctl configs by running `sudo sysctl -p`