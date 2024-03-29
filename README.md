<h1 align="center">
  <a href="https://www.deploykf.org/">deployKF</a>
</h1>

<div align="center">
  <h3>Your Open ML Platform</h3>
</div>

<!-- NOTE: we use this strange picture tag to prevent github making the image clickable -->
<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/deploykf-color.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/deploykf-color.svg">
    <img alt="deployKF Logo" src="https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/deploykf-color.svg" width="140">
  </picture>
</div>

<br>

<div align="center">
  <a href="https://github.com/deployKF/deployKF/stargazers">
    <img alt="GitHub Stars" src="https://img.shields.io/github/stars/deployKF/deployKF?style=for-the-badge&color=ffcb2f&label=Support%20us%20with%20a%20%E2%AD%90%20on%20GitHub" />
  </a>
</div>

<hr>
<br>

# About deployKF

<div>
  <a href="https://github.com/deployKF/deployKF/releases">
    <img alt="Downloads" src="https://img.shields.io/github/downloads/deployKF/deployKF/total?style=flat-square&color=28a745" />
  </a>
  <a href="https://github.com/deployKF/deployKF/fork">
    <img alt="Contributors" src="https://img.shields.io/github/forks/deployKF/deployKF?style=flat-square&color=28a745" />
  </a>
  <a href="https://github.com/deployKF/deployKF/graphs/contributors">
    <img alt="Contributors" src="https://img.shields.io/github/contributors/deployKF/deployKF?style=flat-square&color=28a745" />
  </a>
  <a href="https://github.com/deployKF/deployKF/blob/master/LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/deployKF/deployKF?style=flat-square&color=28a745" />
  </a>
  <a href="https://github.com/deployKF/deployKF/releases">
    <img alt="Latest Release" src="https://img.shields.io/github/v/release/deployKF/deployKF?style=flat-square&color=6f42c1&label=latest%20release" />
  </a>
</div>

## What is deployKF?

> [<img src='https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/deploykf-color.svg' width='20'> __deployKF__](https://www.deploykf.org/) builds machine learning platforms on __Kubernetes__.
> <br>
> We combine the best of
>  [<img src='https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/kubeflow-color.svg' width='20'> __Kubeflow__](https://www.deploykf.org/reference/tools/#kubeflow-ecosystem),
>  [<img src='https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/airflow-color.svg' width='20'> __Airflow__](https://www.deploykf.org/reference/future-tools/#apache-airflow)<sup>†</sup>, and 
>  [<img src='https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/mlflow-color.svg' width='20'> __MLflow__](https://www.deploykf.org/reference/future-tools/#mlflow-model-registry)<sup>†</sup>
> into a complete platform that is easy to deploy and maintain.
>
> <sub><sup>†</sup><sup>Coming soon, see our [current](https://www.deploykf.org/reference/tools/) and [future](https://www.deploykf.org/reference/future-tools/) tools.</sup></sub>

## Why use deployKF?

> deployKF combines the _ease of a managed service_ with the flexibility of a self-hosted solution. 
>
> Our goal is that __any Kubernetes user__ can build a machine learning platform for their organization, 
> without needing specialized MLOps knowledge, or a team of experts to maintain it.
>
> The key features of deployKF are:
>
> - Run on [__any Kubernetes cluster__](https://www.deploykf.org/guides/getting-started/#kubernetes-cluster), including on-premises and in the cloud
> - Intuitive [__centralized configs__](https://www.deploykf.org/guides/values/#overview) for all aspects of the platform
> - Seamless [__in-place upgrades__](https://www.deploykf.org/guides/upgrade/#overview) and config updates
> - Connect your existing
>    [<img src='https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/istio-color.svg' width='20'> __Istio__](https://www.deploykf.org/guides/dependencies/istio/#can-i-use-my-existing-istio),
>    [<img src='https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/cert-manager-color.svg' width='20'> __cert-manager__](https://www.deploykf.org/guides/dependencies/cert-manager/#can-i-use-my-existing-cert-manager),
>    [<img src='https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/kyverno-color.svg' width='20'> __Kyverno__](https://www.deploykf.org/guides/dependencies/kyverno/#can-i-use-my-existing-kyverno),
>    [<img src='https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/s3-color.svg' width='20'> __S3__](https://www.deploykf.org/guides/tools/external-object-store/),
>    and [<img src='https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/mysql-color.svg' width='20'> __MySQL__](https://www.deploykf.org/guides/tools/external-mysql/)
> - Use any [__identity provider__](https://www.deploykf.org/guides/platform/deploykf-authentication/) via _OpenID Connect_ or _LDAP_
> - Native support for [__GitOps with ArgoCD__](https://www.deploykf.org/guides/dependencies/argocd/#how-does-deploykf-use-argo-cd)

## Video Introduction

> <div>
>   <a href="https://www.youtube.com/watch?v=GDX4eLL_8E0" target="_blank" rel="noopener">
>     <img src="https://i.ytimg.com/vi/GDX4eLL_8E0/maxresdefault.jpg" width="720" />
>   </a>
>   <div>
>     <b>Title</b>: deployKF: A better way to deploy Kubeflow (and more)
>     <br>
>     <b>Event</b>: Kubeflow Summit 2023
>   </div>
> </div>

## Featured Stories

> We are always excited to see __how and where__ deployKF is being used!
>
> Here are some stories of deployKF being used in the wild:
>
> Organization | Article / Video
> --- | ---
> <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/cloudflare-color.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/cloudflare-color.svg"><img src="https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/cloudflare-color.svg" width="20"></picture> Cloudflare | [_A look inside the Cloudflare ML Ops platform_](https://blog.cloudflare.com/mlops/)
>
> <sub><sup>
>   <em>Have a story to share? [Let us know](https://www.deploykf.org/about/community/#contact-us)!</em>
> </sup></sub>

---

<br>

# Using deployKF

## Getting Started

> To help you get started with deployKF, we have prepared a number of guides:
> 
> - [⭐ __Getting Started__](https://www.deploykf.org/guides/getting-started/) - learn how to run deployKF anywhere
> - [Local Quickstart](https://www.deploykf.org/guides/local-quickstart/) - try deployKF on your local machine
> - [Migrate from Kubeflow Distributions](https://www.deploykf.org/guides/kubeflow-distributions/) - how and why to migrate from other Kubeflow distributions

## Release Information

> For more information about our releases, please see:
> 
> - [Version Matrix](https://www.deploykf.org/releases/version-matrix/)
> - [Changelog](https://www.deploykf.org/releases/changelog-deploykf/)

## Support the Project

> deployKF is a new and growing project. 
> If you like what we are doing, please help others discover us by __sharing the project__ with your colleagues and/or the wider community.
> 
> We greatly appreciate GitHub Stars ⭐ on the `deployKF/deployKF` repository:
> 
> <picture>
>   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=deploykf/deploykf&type=Date&theme=dark" />
>   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=deploykf/deploykf&type=Date" />
>   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=deploykf/deploykf&type=Date" width="600" />
> </picture>

---

<br>

# Other Resources

## Commercial Support

> To discuss commercial support options for deployKF, please connect with [<img src='https://raw.githubusercontent.com/deployKF/website/main/overrides/.icons/custom/aranui-solutions-color.svg' width='20'> __Aranui Solutions__](https://www.aranui.solutions/), the company started by the creators of deployKF.
> Learn more on the [Aranui Solutions Website](https://www.aranui.solutions/).

## Community

> The deployKF community uses the __Kubeflow Slack__ for informal discussions among users and contributors.
>
> Please see our [community page](https://www.deploykf.org/about/community/#slack) for more information.

## History of deployKF

> deployKF was originally created and is maintained by [Mathew Wicks](https://www.linkedin.com/in/mathewwicks/) (GitHub: [@thesuperzapper](https://github.com/thesuperzapper)), a Kubeflow lead and maintainer of the popular [Apache Airflow Helm Chart](https://github.com/airflow-helm/charts).
> deployKF is a community-led project that welcomes contributions from anyone who wants to help.