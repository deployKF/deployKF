<h1 align="center">deployKF</h1>

<div align="center">
  <h3>Your Open ML Platform</h3>
</div>

<br>

<div align="center">
  <a href="https://www.deploykf.org/" target="_blank" rel="noopener">
    <img src="https://www.deploykf.org/assets/images/logo_1/logo.svg" width="150">
  </a>
</div>

<p align="center">
  <a href="https://www.deploykf.org/" target="_blank" rel="noopener"><b>deployKF</b></a> is a next-generation machine learning toolkit for <a href="https://kubernetes.io/" target="_blank" rel="noopener">Kubernetes</a> which effortlessly integrates <a href="https://www.kubeflow.org/" target="_blank" rel="noopener">Kubeflow</a> and other leading ML/AI tools.
  <br>
  <sub><sub>Crafted with ❤️ by the developers of Kubeflow.</sub></sub>
</p>

<br>

# About

<div>
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
</div>

## What is deployKF?

deployKF is the best way to build reliable ML Platforms on Kubernetes.

- deployKF supports leading [MLOps & Data tools](https://www.deploykf.org/reference/tools/) from both Kubeflow, and other projects
- deployKF has a Helm-like interface, with [values](https://www.deploykf.org/reference/deploykf-values/) for configuring all aspects of the deployment (no need to edit Kubernetes YAML)
- deployKF does NOT install resources directly in your cluster, instead it generates [ArgoCD Applications](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications) to provide native GitOps support

## What ML/AI tools are in deployKF?

Currently, deployKF supports MLOps tools from the Kubeflow ecosystem like [Kubeflow Pipelines](https://www.deploykf.org/reference/tools/#kubeflow-pipelines) and [Kubeflow Notebooks](https://www.deploykf.org/reference/tools/#kubeflow-notebooks).
We are actively adding support for other popular tools such as [MLFlow (Model Registry)](https://www.deploykf.org/reference/future-tools/#mlflow-model-registry), [Apache Airflow](https://www.deploykf.org/reference/future-tools/#apache-airflow), and [Feast](https://www.deploykf.org/reference/future-tools/#feast). 

For more information, please see [supported tools](https://www.deploykf.org/reference/tools/) and [future tools](https://www.deploykf.org/reference/future-tools/)!

## Who makes deployKF?

deployKF was originally created by [Mathew Wicks](https://www.linkedin.com/in/mathewwicks/) (GitHub: [@thesuperzapper](https://github.com/thesuperzapper)), a Kubeflow lead and maintainer of the popular [Apache Airflow Helm Chart](https://github.com/airflow-helm/charts).
However, deployKF is now a community-led project that welcomes contributions from anyone who wants to help.

## Is commercial support available for deployKF?

The creator of deployKF (Mathew Wicks), operates a US-based MLOps company called [Aranui Solutions](https://www.aranui.solutions) that provides commercial support and consulting for deployKF.

Connect on [LinkedIn](https://www.linkedin.com/in/mathewwicks/) or email [`sales@aranui.solutions`](mailto:sales@aranui.solutions?subject=%5BdeployKF%5D%20MY_SUBJECT) to learn more!

## Who uses deployKF?

deployKF is a new project, and we are still building our community.

Please consider adding your organization to our [list of adopters](ADOPTERS.md).

## What is the difference between Kubeflow and deployKF?

Kubeflow and deployKF are two different but related projects:

- deployKF is a tool for deploying Kubeflow and other MLOps tools on Kubernetes as a cohesive platform.
- Kubeflow is a project that develops MLOps tools, including Kubeflow Pipelines, Kubeflow Notebooks, Katib, and more.

For more details, see our detailed [deployKF vs Kubeflow](https://www.deploykf.org/about/kubeflow-vs-deploykf/) comparison.

## Do you have a Slack or Mailing List?

Yes! For more information please see our [community page](https://www.deploykf.org/about/community/).

# Guides

- ### [Getting Started (All Platforms)](https://www.deploykf.org/guides/getting-started/)
- #### [Migrate from Kubeflow Manifests](https://www.deploykf.org/guides/migrate-from-kubeflow-manifests/)

# Media

<div align="center">
  <h3>
    <a href="https://www.youtube.com/watch?v=VggtaOgtBJo" target="_blank" rel="noopener">
      Intro / Demo - Kubeflow Community Call - July 2023
    </a>
  </h3>
  <a href="https://www.youtube.com/watch?v=VggtaOgtBJo" target="_blank" rel="noopener">
    <img src="https://i.ytimg.com/vi/VggtaOgtBJo/maxresdefault.jpg" width="50%">
  </a>
</div>
