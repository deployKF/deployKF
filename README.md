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

You can get started with deployKF by following these steps:

1. fork the `deployKF/deployKF` repository
    - TIP: start from a release branch rather than the current `main`
2. update the `values.yaml` file to suite your environment
3. generate the manifests by running `run_generator.sh` 
4. add the generated files to your git repository using `git add GENERATOR_OUTPUT` 
5. manually apply the generated ArgoCD ["app of apps"](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern) to your Kubernetes cluster:
    - `kubectl apply --filename GENERATOR_OUTPUT/app-of-apps.yaml`
6. sync the ArgoCD applications __IN THE FOLLOWING ORDER__:
    1. `kubeflow-app-of-apps`
    2. __cluster-dependencies__ _(label: `app.kubernetes.io/component: cluster-dependencies`)_
        1. `kf-dep--kyverno`
        2. `kf-dep--cert-manager`
            - _WARNING: first sync may fail as trust-manager depends on cert-manager, so once cert-manager pods are up, terminate the first hung sync (under "SYNC STATUS"), and sync again_
        3. `kf-dep--sealed-secrets`
        4. `kf-dep--istio`
            - _WARNING: first sync may fail, so wait and sync again_
        5. `kf-dep--knative--knative-eventing`
        6. `kf-dep--knative--knative-serving`
    3. __kubeflow-common__ _(label: `app.kubernetes.io/component: kubeflow-common`)_
        1. `kf-common--kubeflow-istio-gateway`
        2. `kf-common--kubeflow-auth`
        3. `kf-common--kubeflow-dashboard`
        4. `kf-common--minio`
        5. `kf-common--mysql`
        6. `kf-common--argo-workflows`
        7. `kf-common--kubeflow-profiles-generator`
            - _WARNING: first sync may fail as profile namespaces will not immediately be created, so wait for those namespace to be created, and sync again_
    4. __kubeflow-apps__ _(label: `app.kubernetes.io/component: kubeflow-apps`)_
        1. `kf-app--pipelines`
        2. `kf-app--poddefaults-webhook`
        3. `kf-app--notebooks--notebook-controller` 
        4. `kf-app--notebooks--jupyter-web-app`
        5. `kf-app--tensorboards--tensorboard-controller`
        6. `kf-app--tensorboards--tensorboards-web-app`
        7. `kf-app--volumes--volumes-web-app`
        8. `kf-app--training-operator`
        9. `kf-app--katib`
    5. __kubeflow-contrib__ _(label: `app.kubernetes.io/component: kubeflow-contrib`)_
        1. `kf-contrib--kserve--kserve`
        2. `kf-contrib--kserve--models-web-app`
7. access the Kubeflow UI through the Istio Gateway Service:
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

## Troubleshooting

### ERROR: pods fail with "too many open files"

This error has been [discussed in upstream kubeflow repos](https://github.com/kubeflow/manifests/issues/2087), to resolve it you will need to increase your system's open/watched file limits.

On linux, you may need to increase the `fs.inotify.max_user_*` sysctl values, here are some values which users have reported to work:

1. Modify `/etc/sysctl.conf` to include the following lines:
    - `fs.inotify.max_user_instances = 1280`
    - `fs.inotify.max_user_watches = 655360`
2. Reload sysctl configs by running `sudo sysctl -p`