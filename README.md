<!-- badges: start -->

[![R build
status](https://github.com/ropensci-review-tools/orgmetricsDashboard/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ropensci-review-tools/orgmetricsDashboard/actions?query=workflow%3AR-CMD-check.yaml)
[![codecov](https://codecov.io/gh/ropensci-review-tools/orgmetricsDashboard/branch/main/graph/badge.svg)](https://app.codecov.io/gh/ropensci-review-tools/orgmetricsDashboard)
[![Project Status:
Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

# orgmetricsDashboard

A dashboard for your GitHub organization, collated from applying accompanying
[`orgmetrics`](https://docs.ropensci.org/orgmetrics/) and
[`repometrics` packages](https://docs.ropensci.org/repometrics/)
across all organization repositories. This is a lightweight package to enable
organizational dashboards to be generated and published without installing all of the 
necessary software (which is a large portion of the entire
[`ropensci-review-tools` software
suite](https://github.com/ropensci-review-tools).) The package can be installed almost instantaneously, and offers two easy ways to generate a dashboard:

1. Via a GitHub Actions workflow file; or
2. Via a Docker container which can be run locally to generate and publish your
   dashboard, and which may then be deleted after use.

A demonstration dashboard of the entire rOpenSci organization is currently at
[ropensci-review-tools.github.io/orgmetrics-ropensci/](https://ropensci-review-tools.github.io/orgmetrics-ropensci/).

## How?

Dashboards are intended to be generated from an [R-universe
repository](https://docs.r-universe.dev/publish/set-up.html) containing a
["packages.json" file](https://docs.r-universe.dev/publish/set-up.html).
The dashboard will be generated for all packages listed in that file, and for
all people who have contributed to those packages. The main input required is
the URL of an R-universe repository on GitHub. If you don't have one of those,
read the documents linked here first, set up your repo and "packages.json"
file, and then continue here.

### Installation

First, install the package either via [`r-universe`](https://r-universe.dev):

``` r
options (repos = c (
    ropenscireviewtools = "https://ropensci-review-tools.r-universe.dev",
    CRAN = "https://cloud.r-project.org"
))
install.packages ("orgmetricsDashboard")
```
or directly from GitHub with one of these two lines:


``` r
remotes::install_github ("ropensci-review-tools/orgmetricsDashboard")
pak::pkg_install ("ropensci-review-tools/orgmetricsDashboard")
```

The package may also be installed from locations other than GitHub, with any of
the following options:
``` r
remotes::install_git ("https://codeberg.org/ropensci-review-tools/orgmetricsDashboard")
remotes::install_git ("https://codefloe.com/ropensci-review-tools/orgmetricsDashboard")
```

## Usage

As described above, this package provides two main approaches for creating an
orgmetrics dashboard for your GitHub organization:

### 1. GitHub Actions Workflow

Use `use_github_action_orgmetrics()` to create a GitHub Actions workflow file
that will automatically build and deploy your dashboard on a schedule or push
to main:

``` r
library(orgmetricsDashboard)

# Create a workflow file in the default location
use_github_action_orgmetrics()
```

This creates `.github/workflows/orgmetrics.yaml` which will run on a daily
schedule (midnight UTC), or on a push to main branch, and will render and
publish your dashboard to GitHub Pages.

#### Issues with GitHub Actions workflow

The GitHub Actions workflow will generally make a large number of calls to the
GitHub API. When run on GitHub machines, this large volume of calls may
ultimately be rate limited. Resultant dashboards in such cases may be missing
data. This behaviour is neither reproducible, nor able to be resolved, so if
you do encounter empty or missing data, it is recommended to use the second
method.

### 2. Docker Container

An `orgmetrics` dashboard can be generated locally without installing any of
the required software by running the `orgmetrics_docker()` function. This will
download a [pre-generated Docker
container](https://ghcr.io/ropensci-review-tools/orgmetrics:latest) container, and run
all analyses within that container on your local machine.

You'll first need to install this very lightweight package, and pull the docker
image (of size <2GB):

``` r
library(orgmetricsDashboard)
docker_pull_orgmetrics_image()
```

You can then run the container to build and optionally publish your dashboard
with this function:

``` r
orgmetrics_docker(
  repo_url = "https://github.com/your-org/your-r-universe-repo",
  github_name = "your-username",
  git_email = "your-email@example.com",
  quarto_local = TRUE,
  quarto_publish = TRUE,
  quarto_provider = "gh-pages"
)
```

The `quarto_local` parameter generates a `./quarto/` directory in the location
where the function is called. When the function has finished, that directory
will contain all of the [Quarto](https://quarto.org) files needed to generate
your dashboard. You can then edit those files anyway you like, and publish
yourself to any provider you like with the `quarto publish` command.

## Code of Conduct

Please note that this package is released with a [Contributor Code of
Conduct](https://ropensci.org/code-of-conduct/). By contributing to this
project, you agree to abide by its terms.
