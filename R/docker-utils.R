is_docker_installed <- function () {

    dv <- suppressWarnings (
        system2 ("docker", "-v", stdout = TRUE)
    )

    any (grepl ("Docker version", dv))
}

is_docker_running <- function () {

    if (!is_docker_installed ()) {
        return (FALSE)
    }

    info <- suppressWarnings (
        system2 ("docker", "info", stdout = TRUE, stderr = FALSE)
    )
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
    i <- grep ("orgmetrics:latest", di$IMAGE, value = FALSE)
    di$ID [i]
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

    length (docker_orgmetrics_image ()) > 0L
}
