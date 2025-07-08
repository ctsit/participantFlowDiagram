#' Create a named vector for relabeling a gtsummary table
#'
#' @description
#' Get a named vector we can use to relabel a gtsummary table
#'
#' @param pretty_labels a data like those returned by
#' [get_pretty_labels_template()], but with pretty labels in place of the
#' templated values.
#'
#' @returns a named vector of pretty labels with the plain labels as the names
#' @keywords Internal
#'
#' @examples
#' \dontrun{
#'   get_table_summary_labels(pretty_labels)
#' }
get_table_summary_labels <- function(pretty_labels) {
  table_summary_labels <- pretty_labels |>
    dplyr::select("plain_label", "pretty_label") |>
    tibble::deframe() |>
    as.list()

  return(table_summary_labels)
}
