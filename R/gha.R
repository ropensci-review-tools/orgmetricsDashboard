#' Use orgemtrics Github Action
#'
#' Creates a Github workflow file in `dir` to automatically deploy your
#' 'orgmetrics' dashboard.
#'
#' @param dir Directory the file is written to.
#' @param overwrite Overwrite existing file?
#' @param file_name Name of the workflow file.
#' @return The path to the new file, invisibly.
#'
#' @export
use_github_action_orgmetrics <- function (dir = ".github/workflows",
                                          overwrite = FALSE,
                                          file_name = "orgmetrics.yaml") {

    if (!is.character (file_name)) {
        cli::cli_abort ("{.arg file_name} must be a character argument")
    }
    if (length (file_name) != 1L) {
        cli::cli_abort ("{.arg file_name} must be a single value")
    }
    dir <- fs::path_abs (dir)
    if (!fs::dir_exists (dir)) {
        fs::dir_create (dir, recurse = TRUE)
    }
    path <- fs::path (dir, file_name)
    if (fs::file_exists (path) && !overwrite) {
        cli::cli_abort (
            c (
                "The file {.file {path}} already exists!",
                i = "Use {.arg overwrite = TRUE} to replace the existing file."
            )
        )
    }

    yaml <- system.file (
        "extdata",
        "orgmetrics.yaml",
        package = "orgmetricsDashboard",
        mustWork = TRUE
    )

    fs::file_copy (yaml, path)

    cli::cli_alert_success (
        "File {.file {file_name}} succesfully writen to {.path {dir}}!"
    )

    invisible (path)
}
