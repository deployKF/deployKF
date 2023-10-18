<h1 align="center">deployKF</h1>

<div align="center">
  <h3>Your Open ML Platform</h3>
</div>

<div align="center">
  <a href="https://www.deploykf.org/" target="_blank" rel="noopener">
    <img src="https://www.deploykf.org/assets/images/logo_1/logo.svg" width="140">
  </a>
</div>

<hr>

<p align="center">
  <a href="https://www.deploykf.org/" target="_blank" rel="noopener"><b>deployKF</b></a> builds world-class ML Platforms on <strong>any Kubernetes cluster</strong>, within <strong>any cloud or environment</strong>, in minutes.
  <br>
  <br>
  With <em>centralized configs</em>, in-place upgrades, and support for leading ML & Data tools like 
  <a href="https://www.deploykf.org/reference/tools/#kubeflow-ecosystem"><strong>Kubeflow</strong></a>,
  <a href="https://www.deploykf.org/reference/future-tools/#apache-airflow"><strong>Airflow</strong><sup>†</sup></a>, and
  <a href="https://www.deploykf.org/reference/future-tools/#mlflow-model-registry"><strong>MLflow</strong><sup>†</sup></a>,
  deployKF lets you focus on using the platform, not building it.
  <br>
  <sub><sup>†</sup><sup>Coming soon, see our <a href="https://www.deploykf.org/reference/tools/" target="_blank" rel="noopener">current</a> and <a href="https://www.deploykf.org/reference/future-tools/" target="_blank" rel="noopener">future</a> tools.</sup></sub>
</p>

<hr>
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

deployKF builds world-class ML Platforms on __any Kubernetes cluster__, within __any cloud or environment__, in minutes.

- deployKF includes [__leading ML & Data tools__](https://www.deploykf.org/reference/tools/) from Kubeflow and more
- deployKF has [__centralized configs__](https://www.deploykf.org/reference/deploykf-values/) that manage all aspects of the platform
- deployKF supports __in-place upgrades__ and can __autonomously__ roll out config changes
- deployKF lets you __bring your own__ cluster dependencies like __istio__ and __cert-manager__, if desired
- deployKF uses __ArgoCD Applications__ to provide native GitOps support

## What ML and AI tools are in deployKF?

deployKF supports all tools from the [Kubeflow Ecosystem](https://www.deploykf.org/reference/tools/#kubeflow-ecosystem) including [__Kubeflow Pipelines__](https://www.deploykf.org/reference/tools/#kubeflow-pipelines) and [__Kubeflow Notebooks__](https://www.deploykf.org/reference/tools/#kubeflow-notebooks).
We are actively adding support for other popular tools such as [__MLflow__](https://www.deploykf.org/reference/future-tools/#mlflow-model-registry), [__Airflow__](https://www.deploykf.org/reference/future-tools/#apache-airflow), and [__Feast__](https://www.deploykf.org/reference/future-tools/#feast). 

For more information, please see our [current](https://www.deploykf.org/reference/tools/) and [future](https://www.deploykf.org/reference/future-tools/) tools!

## Who makes deployKF?

deployKF was originally created by [Mathew Wicks](https://www.linkedin.com/in/mathewwicks/) (GitHub: [@thesuperzapper](https://github.com/thesuperzapper)), a Kubeflow lead and maintainer of the popular [Apache Airflow Helm Chart](https://github.com/airflow-helm/charts).
deployKF is a community-led project that welcomes contributions from anyone who wants to help.

## Is commercial support available for deployKF?

The creator of deployKF (Mathew Wicks), operates a US-based ML & Data company named [__Aranui Solutions__](https://www.aranui.solutions) which provides __commercial support__ and __advisory services__.

Connect on [LinkedIn](https://www.linkedin.com/in/mathewwicks/) or email [`sales@aranui.solutions`](mailto:sales@aranui.solutions?subject=%5BdeployKF%5D%20MY_SUBJECT) to learn more!

## Who uses deployKF?

deployKF is a new project, and we are still building our community, consider [adding your organization](ADOPTERS.md) to our list of adopters.

## What is the difference between Kubeflow and deployKF?

Kubeflow and deployKF are two different but related projects.

For more details, please see our [deployKF vs Kubeflow](https://www.deploykf.org/about/kubeflow-vs-deploykf/) comparison.

## Do you have a Slack or Mailing List?

Yes! For more information please see our [community page](https://www.deploykf.org/about/community/).

# Documentation

## Admin Guides

- ### [Getting Started (Production Usage) ⭐](https://www.deploykf.org/guides/getting-started/)
- #### [Local Quickstart ⭐](https://www.deploykf.org/guides/local-quickstart/)
- #### [Migrate from Kubeflow Manifests](https://www.deploykf.org/guides/migrate-from-kubeflow-manifests/)

## Release Information

- #### [Version Matrix](https://www.deploykf.org/releases/version-matrix/)
- #### [Changelog](https://www.deploykf.org/releases/changelog-deploykf/)

## Media

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
