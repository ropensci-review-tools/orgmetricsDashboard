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

docker_has_orgmetrics_image <- function () {

    di <- docker_images_list ()
    any (grepl ("orgmetrics:latest", di$IMAGE))
}

docker_pull_orgmetrics_image <- function () {

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
