#' Create a diagram to show participant progress through a study workflow
#'
#' @description
#' Create a diagram to show participant progress through a study workflow via
#' the counts of study participants who reach each point in the study workflow.
#' Create the diagram diagram from a detailed dataframe, describing the
#' progress of each research participant, the parent child relationships
#' that define the study progression, and pretty labels for each state
#' and step in the protocol.
#'
#' @param participant_level_progress A detail dataframe describing the progress
#'        of each research participant
#' @param parents A vector nodes of the diagram that have children
#' @param children A vector enumerating the child categorical level below the
#'        corresponding parent
#' @param pretty_labels A dataframe defining the pretty labels for each step
#'        and each factor level
#' @param render A logical to indicate if the mermaid syntax should be
#'        rendered into a diagram or if the syntax should be returned
#'        (default = TRUE)
#'
#' @returns A plot of the study progress or the mermaid syntax to generate it
#' @export
#'
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' create_mermaid_diagram(
#'   participant_level_progress = participant_level_progress,
#'   parents = steps$parent,
#'   children = steps$child,
#'   pretty_labels = pretty_labels
#' )
#' }
create_mermaid_diagram <- function(participant_level_progress,
                                   parents,
                                   children,
                                   pretty_labels,
                                   render = TRUE) {

  checkmate::assert_logical(render)
  checkmate::assert_vector(parents)
  checkmate::assert_vector(children)
  if (length(children) != length(parents)) {
    stop("Length of 'children' and 'parents' must be the same")
  }

  summary_table <-
    participant_level_progress |>
    gtsummary::tbl_summary(
      include = children,
      sort = gtsummary::all_categorical() ~ "frequency"
    ) |>
    purrr::pluck("table_body") |>
    dplyr::select("variable", plain_label = "label", n = "stat_0") |>
    dplyr::filter(!is.na(.data$n) & .data$plain_label != "Unknown") |>
    dplyr::mutate(n = readr::parse_number(.data$n)) |>
    dplyr::left_join(pretty_labels |>
      dplyr::filter(.data$row_type == "label") |>
      dplyr::select("plain_label", variable_pretty = "pretty_label"), by = c("variable" = "plain_label")) |>
    dplyr::left_join(pretty_labels |>
      dplyr::filter(.data$row_type == "level") |>
      dplyr::select("plain_label", "pretty_label"), by = c("plain_label" = "plain_label"))

  parent_child_nodes <- data.frame(
    parent_node = c(parents[1], parents),
    child_node = c(NA, children)
  )

  mermaid_data <-
    parent_child_nodes |>
    dplyr::left_join(summary_table, by = c("child_node" = "variable")) |>
    dplyr::mutate(pretty_label = stringr::str_replace_all(.data$pretty_label, "\n", " <br/>")) |>
    dplyr::mutate(
      syntax = dplyr::case_when(
        is.na(.data$child_node) ~ paste0(parents[1], "[", parents[1], "<br/>n = ", nrow(participant_level_progress), "]"),
        TRUE ~ paste0(.data$parent_node, "-->", .data$plain_label, '["', .data$pretty_label, '"<br/>n = ', n, "]")
      )
    )

  mermaid_syntax <- paste("graph TD;", paste(mermaid_data$syntax, collapse = "; "))

  if (render) {
    return(DiagrammeR::mermaid(mermaid_syntax))
  } else {
    return(mermaid_syntax)
  }
}
