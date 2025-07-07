#' get_participant_level_progress_pretty
#' @description
#' Replace plain text labels with pretty labels in `participant_level_progress`
#'
#' @param participant_level_progress A detail dataframe describing the progress
#'        of each research participant
#' @param pretty_labels a data like those returned by
#' [get_pretty_labels_template()], but with pretty labels in place of the
#' templated values.
#'
#' @returns a dataframe the same structure as `participant_level_progress`,
#'          but with pretty labels in the data fields in place of the plain
#'          labels.
#' @keywords Internal
#'
#' @examples
#' \dontrun{
#'   get_participant_level_progress_pretty(
#'     participant_level_progress,
#'     pretty_labels
#'   )
#' }
get_participant_level_progress_pretty <- function(
    participant_level_progress,
    pretty_labels
    ) {

  df_to_named_vector <- function(participant_level_progress) {
    if (ncol(participant_level_progress) != 2) {
      stop("The dataframe must have exactly two columns.")
    }

    names <- participant_level_progress[[1]]
    values <- as.character(participant_level_progress[[2]])

    if (any(duplicated(names))) {
      stop("The first column must not have duplicate values.")
    }

    named_vector <- stats::setNames(values, names)
    return(named_vector)
  }

  levels_map <- split(pretty_labels, pretty_labels$variable) |>
    purrr::map(~ df_to_named_vector(.x |> dplyr::select("pretty_label", "plain_label")))

  participant_level_progress_pretty <- participant_level_progress
  for (var in names(levels_map)) {
    participant_level_progress_pretty[[var]] <-
      forcats::fct_recode(
        participant_level_progress_pretty[[var]],
        !!!levels_map[[var]]
      )
  }

  return(participant_level_progress_pretty)
}
