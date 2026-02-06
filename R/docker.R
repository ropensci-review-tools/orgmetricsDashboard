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
#'
#' @export
orgmetrics_docker <- function (repo_url = NULL,
                               github_name = NULL,
                               git_email = NULL,
                               quarto_local = TRUE,
                               quarto_publish = TRUE,
                               quarto_provider = "gh-pages") {

}

orgmetrics_container_url <- "ghcr.io/ropensci-review-tools/orgmetrics:latest"

is_docker_installed <- function () {
    dv <- system2 ("docker", "-v", stdout = TRUE)

    any (grepl ("Docker version", dv))
}

is_docker_running <- function () {

    if (!is_docker_installed ()) {
        return (FALSE)
    }

    info <- system2 ("docker", "info", stdout = TRUE, stderr = FALSE)
    i <- grep ("^Server\\:", info)
    length (info) > i
}

docker_images_list <- function () {

    if (!is_docker_running ()) {
        return (NULL)
    }

    images <- system2 ("docker", "images", stdout = TRUE, stderr = FALSE)
    if (length (images) > 0L) {
        images <- lapply (images, function (i) strsplit (i, "\\s+") [[1]] [1:2])
        nms <- images [[1]]
        images <- data.frame (do.call (rbind, images [-1]))
        names (images) <- nms
    }

    return (images)
}

docker_orgmetrics_image <- function () {

    di <- docker_images_list ()
    grep ("orgmetrics:latest", di$IMAGE, value = TRUE)
}

#' Pull the 'orgmetrics' docker container for local use.
#'
#' @examples
#' \dontrun{
#' docker_pull_orgmetrics_image ()
#' }
#' @export
docker_pull_orgmetrics_image <- function () {

    if (length (docker_orgmetrics_image ()) > 0L) {
        msg <- paste0 (
            "Docker already has the 'orgmetrics' image; if you want ",
            "to pull again, please 'docker rmi' this image first."
        )
        cli::cli_inform (msg)
        return (FALSE)
    }

    msg <- "Docker needs to 'pull' the orgmetrics container"
    cli::cli_inform (msg)

    if (!cli::has_keypress_support ()) {
        msg <- paste0 (
            "Your environment does not support key ",
            "entry, downloading will now proceed."
        )
        cli::cli_alert_warning (msg)
    } else {
        cli::cli_alert_info ("Do you want to proceed (y/n)?")
        k <- tolower (cli::keypress ())
        if (!k %in% c ("y", "n")) {
            cli::cli_abort ("Only 'y' or 'n' are recognised.")
        }
        if (k == "n") {
            cli::cli_abort ("Okay, stopping there")
        }
    }

    system (paste0 ("docker pull ", orgmetrics_container_url))

    docker_has_orgmetrics_image ()
}

create_dotenv_file <- function (path = ".",
                                repo_url = NULL,
                                github_name = NULL,
                                git_email = NULL,
                                quarto_local = TRUE,
                                quarto_publish = TRUE,
                                quarto_provider = "gh-pages") {

    if (is.null (repo_url)) {
        repo_url <- gert::git_remote_list (repo = path)
        repo_url <- grep ("github\\.com", repo_url$url, value = TRUE)
    }
    checkmate::assert_character (repo_url, len = 1L)

    w <- whoami::whoami ()
    if (is.null (github_name)) {
        github_name <- w [["gh_username"]]
    }
    if (is.null (git_email)) {
        git_email <- w [["email_address"]]
    }
    checkmate::assert_character (github_name, len = 1L)
    checkmate::assert_character (git_email, len = 1L)

    if (!quarto_publish && !quarto_local) {
        cli::cli_abort (paste0 (
            "Turning off publishing without creating a local ",
            "quarto sub-directory means this function will do nothing. ",
            "Stopping now"
        ))
    }

    gh_tok <- gitcreds::gitcreds_get ()$password
    checkmate::assert_character (gh_tok, len = 1L)

    checkmate::assert_logical (quarto_local, len = 1L)
    checkmate::assert_logical (quarto_publish, len = 1L)
    quarto_local <- ifelse (quarto_local, "true", "false")
    quarto_publish <- ifelse (quarto_publish, "true", "false")

    checkmate::assert_character (quarto_provider, len = 1L)

    env <- c (
        "# ------ IMPORTANT! ------",
        "# All variables should be defined here WITHOUT quotation marks.",
        "",
        "# GitHub credentials",
        paste0 ("GITHUB_TOKEN=", gh_tok),
        paste0 ("GITHUB_PAT=", gh_tok),
        "",
        "# Git user config",
        paste0 ("GIT_USER_NAME=", github_name),
        paste0 ("GIT_USER_EMAIL=", git_email),
        "",
        "# R-universe-like repo containing 'packages.json' file to populate dashboard.",
        paste0 ("GIT_REMOTE_URL=", repo_url),
        paste0 ("QUARTO_PUBLISH=", quarto_publish),
        paste0 ("QUARTO_PROVIDER=", quarto_provider)
    )

    f <- fs::path_abs (".env")
    writeLines (env, f)
    cli::cli_alert_info ("Docker environment information written to {f}")
    cli::cli_inform ("This file may be deleted after dashboard has been successfully deployed.")

    return (f)
}
