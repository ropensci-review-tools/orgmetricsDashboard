#' Run `orgemtrics` in local Docker container
#'
#' Downloads the 'orgmetrics' docker container and uses that to build a
#' dashboard of your r-universe-like GitHub organization.
#'
#' @param repo_url URL of GitHub repository of R-universe-like repository
#' containing a "packages.json" file. If not specified, the Git remote URL of
#' the repository in the current working directory will be used.
#' @param github_name Your username on GitHub. If not specified, value will be
#' taken from \pkg{whoami}.
#' @param git_email Your email used in Git commits. If not specified, value
#' will be taken from \pkg{whoami}.
#' @param quarto_local If `TRUE` (default), the Docker command will create a
#' `quarto/` sub-directory in the directory where this function is called.
#' This may be used in conjunction with `quarto_publish = FALSE` to create local
#' `quarto/` sub-directory only, without publishing. The contents of the
#' resultant directory can then be edited or changed in any way, and `quarto
#' publish` run locally there, to enable complete control over the process.
#' @param quarto_publish If `TRUE` (default), publish dashboard directly to the
#' nominated Quarto service provider.
#' @param quarto_provider Provider of service where dashboard is to be
#' published.
#'
#' @return Nothing.
#' @examples
#' \dontrun{
#' # First pull the Docker image
#' docker_pull_orgmetrics_image ()
#'
#' # Run the container to build your dashboard locally
#' orgmetrics_docker (
#'     repo_url = "https://github.com/your-org/your-r-universe-repo",
#'     github_name = "your-username",
#'     git_email = "your-email@example.com"
#' )
#' }
#'
#' @export
orgmetrics_docker <- function (repo_url = NULL,
                               github_name = NULL,
                               git_email = NULL,
                               quarto_local = TRUE,
                               quarto_publish = TRUE,
                               quarto_provider = "gh-pages") {

    if (!is_docker_running ()) {
        cli::cli_abort ("This requires docker to be running on your system.")
    }
    if (length (docker_orgmetrics_image ()) < 1L) {
        docker_pull_orgmetrics_image ()
    }

    f <- create_dotenv_file (
        repo_url = repo_url,
        github_name = github_name,
        git_email = git_email,
        quarto_local = quarto_local,
        quarto_publish = quarto_publish,
        quarto_provider = quarto_provider
    )

    params <- c ("--rm", "--env-file", ".env")
    if (quarto_local) {
        path <- fs::path_abs (".")
        path_dir <- fs::path_file (path)
        params <- c (
            params,
            "-v",
            paste0 (path, ":/mnt/", path_dir)
        )
    }

    run_params <- c (
        "run",
        params,
        docker_orgmetrics_image ()
    )

    system2 ("docker", run_params)
}

orgmetrics_container_url <- "ghcr.io/ropensci-review-tools/orgmetrics:latest"
