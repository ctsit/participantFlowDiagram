#' Create a table to summarize participant progress
#'
#' @description
#' Create a table showing the counts of study participants who reached each point in the study workflow
#'
#' @param participant_level_progress A detail dataframe describing the progress
#'        of each research participant
#' @param pretty_labels A dataframe defining the pretty labels for each step
#'        and each factor level
#' @param children A vector enumerating the child categorical level below the
#'        corresponding parent
#'
#' @returns a gtsummary::tbl_summary() object that describes
#'          `participant_level_progress` using the labels in `pretty_labels`
#' @export
#'
#' @examples
#' \dontrun{
#' gtsummary_table <- create_table(participant_level_progress, pretty_labels)
#' }
create_table <- function(
    participant_level_progress,
    children,
    pretty_labels
    ) {
  table_summary_labels <- get_table_summary_labels(pretty_labels)

  participant_level_progress_pretty <- get_participant_level_progress_pretty(
    participant_level_progress = participant_level_progress,
    pretty_labels
  )

  gt_table <- participant_level_progress_pretty |>
    gtsummary::tbl_summary(include = children,
                           label = table_summary_labels,
                           missing = "no",
                           sort =  gtsummary::all_categorical() ~ "frequency")

  return(gt_table)
}
