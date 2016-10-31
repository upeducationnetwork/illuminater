#' Gradebook Components
#'
#' These functions allow you to components of a gradebook out of Illuminate, without the underlying data contained within those components.
#' \itemize{
#'  \item \code{il_gradebook_assignments()}: All assignments in a gradebook
#' }
#'
#' @param connection The connection object from your \code{il_connect} call
#' @name il_gradebook_components
#' @return A dataframe with the result of the call.
NULL


#' @export
#' @rdname il_gradebook_components
il_gradebook_assignments <- function(connection){
  # Assignment information from gradebook.assignments table.
  # TODO: Add option to get specific gradebooks
  query <- "
  SELECT
    asg.assignment_id,
    asg.short_name,
    asg.long_name,
    asg.assign_date,
    asg.due_date,
    asg.possible_points,
    asg.category_id,
    asg.is_active,
    asg.description,
    asg._grading_period_id,
    asg.auto_score_type,
    asg.auto_score_id,
    asg.possible_score,
    asg.gradebook_id,
    asg.last_modified_by,
    asg.is_extra_credit,
    asg.tags,
    gb.created_by,
    gb.gradebook_name,
    gb.active,
    gb.academic_year,
    gb.is_deleted,
    users.first_name,
    users.last_name,
    users.local_user_id,
    catname.category_name,
    catname.weight
  FROM gradebook.assignments As asg
  INNER JOIN gradebook.gradebooks AS gb ON gb.gradebook_id = asg.gradebook_id
  INNER JOIN public.users As users ON users.user_id = gb.created_by
  LEFT JOIN gradebook.categories As catname ON catname.category_id = asg.category_id AND catname.gradebook_id = asg.gradebook_id"

  message("Getting Assignment Information")
  DBI::dbGetQuery(connection, query)
}
