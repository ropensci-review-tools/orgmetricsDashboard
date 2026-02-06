#' Use orgemtrics Github Action
#'
#' Creates a Github workflow file in `dir` to automatically deploy your
#' 'orgmetrics' dashboard.
#'
#' @param dir Directory the file is written to.
#' @param overwrite Overwrite existing file?
#' @param file_name Name of the workflow file.
#' @param inputs Named list of inputs to the
#'   `ropensci-review-tools/pkgcheck-action`. See details below.
#' @return The path to the new file, invisibly.
#' @details For more information on the action and advanced usage visit the
#' action
#' [repository](https://github.com/ropensci-review-tools/pkgcheck-action).
#' @section Inputs:
#' Inputs with description and default values. Pass all values as strings, see
#' examples.
#'
#' ```yaml
#' inputs:
#'   ref:
#'     description: "The ref to checkout and check. Set to empty string to skip checkout."
#'     default: "${{ github.ref }}"
#'     required: true
#'   post-to-issue:
#'     description: "Should the pkgcheck results be posted as an issue?"
#'     # If you use the 'pull_request' trigger and the PR is from outside the repo
#'     # (e.g. a fork), the job will fail due to permission issues
#'     # if this is set to 'true'. The default will prevent this.
#'     default: ${{ github.event_name != 'pull_request' }}
#'     required: true
#'   issue-title:
#'     description: "Name for the issue containing the pkgcheck results. Will be created or updated."
#'     # This will create a new issue for every branch, set it to something fixed
#'     # to only create one issue that is updated via edits.
#'     default: "pkgcheck results - ${{ github.ref_name }}"
#'     required: true
#'   summary-only:
#'     description: "Only post the check summary to issue. Set to false to get the full results in the issue."
#'     default: true
#'     required: true
#'   append-to-issue:
#'     description: "Should issue results be appended to existing issue, or posted in new issues."
#'     default: true
#'     required: true
#' ```
#' @examples
#' \dontrun{
#' use_github_action_pkgcheck (inputs = list (`post-to-issue` = "false"))
#' }
#' @family github
#' @export
use_github_action_orgmetrics <- function (dir = ".github/workflows",
                                          overwrite = FALSE,
                                          file_name = "orgmetrics.yaml",
                                          inputs = NULL) {

    if (!is.character (file_name)) {
        cli::cli_abort ("{.arg file_name} must be a character argument")
    }
    if (length (file_name) != 1L) {
        cli::cli_abort ("{.arg file_name} must be a single value")
    }
    dir <- normalizePath (dir, mustWork = FALSE)
    if (!dir.exists (dir)) {
        dir.create (dir, recursive = TRUE)
    }
    path <- fs::path (dir, file_name)
    if (file.exists (path) && !overwrite) {
        cli::cli_abort (
            c (
                "The file {.file {path}} already exists!",
                i = "Use {.arg overwrite = TRUE} to replace the existing file."
            )
        )
    }

    yaml <- system.file (
        "extdata",
        "dashboard.yaml",
        package = "orgmetricsDashboard",
        mustWork = TRUE
    ) |> readLines ()

    if (!is.null (inputs)) {
        if (!is.list (inputs) || is.null (names (inputs))) {
            cli::cli_abort ("{.arg inputs} must be a named list!")
        }

        valid_inputs <- c (
            "ref",
            "post-to-issue",
            "issue-title",
            "summary-only"
        )
        broken_inputs <- !(names (inputs) %in% valid_inputs)

        if (any (broken_inputs)) {
            cli::cli_abort (
                c (
                    paste0 (
                        "The following {.arg inputs} are not valid: ",
                        "{ names (inputs)[broken_inputs] }"
                    ),
                    i = "Please check {.code ?use_github_check} for valid inputs."
                )
            )
        }

        # YAML indentation uses space not tabs
        with <- glue::glue ("        with:")
        inputs <- glue::glue ("          {names (inputs)}: {inputs}")
        inputs <- c (with, inputs)
    }

    yaml <- c (yaml, inputs)

    writeLines (yaml, path)

    cli::cli_alert_success (
        "File {.file {file_name}} succesfully writen to {.path {dir}}!"
    )

    invisible (path)
}
