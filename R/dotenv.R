#' Create a '.env' file to pass to docker
#'
#' Used in \link{orgmetrics_docker}, with all parameters passed directly from
#' there.
#'
#' @inheritParams orgmetrics_docker
#' @noRd
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
