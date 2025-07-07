#' get_pretty_labels_template
#'
#' @description
#' Generate a dataframe describing the steps and factor levels in the study
#' workflow to assist in setting pretty labels for each step and factor level.
#'
#' @param participant_level_progress A detail dataframe describing the progress
#'        of each research participant
#' @param parents A vector nodes of the diagram that have children
#' @param children A vector enumerating the child categorical level below the
#'        corresponding parent
#'
#' @returns A data frame with on row for each step in the study and one row
#'          for each factor level at each step. The data frame has these columns:
#' \itemize{
#'   \item variable - the factor for this level
#'   \item row_type - a character string indicating if this row describes a step
#'         of the factor values on that step
#'   \item plain_label - the existing label derived from the step or its factor level
#'   \item pretty_label - the pretty label to use in place of label

#' }
#' @export
#'
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' get_pretty_labels_template(
#'   participant_level_progress = progress_detail,
#'   parents = steps$parent,
#'   children = steps$child
#' )
#' }
get_pretty_labels_template <- function(
    participant_level_progress,
    parents,
    children
    ) {

  result <- participant_level_progress |>
    gtsummary::tbl_summary(
      include = children,
      missing = "no"
    ) |>
    purrr::pluck("table_body") |>
    dplyr::select("variable", "row_type", plain_label = "label") |>
    dplyr::mutate(pretty_label = .data$plain_label)

  return(result)
}
