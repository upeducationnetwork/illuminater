#' Gradebook Grades
#'
#' These functions will allow you to get gradebook data out of Illuminate
#' \itemize{
#'  \item \code{il_gradebook_overall()}: Overall grades from points-based gradebooks
#'  \item \code{il_gradebook_categories()}: Category data from a points-based gradebook
#'  \item \code{il_gradebook_assignments()}: Assignments data from an assignments-based gradebook
#'  \item \code{il_gradebook_standards()}: Standards data from a standards-based gradebook
#' }
#'
#' @param connection The connection object from your \code{il_connect} call
#' @name il_gradebook_grades
#' @return A dataframe with the result of the call.
#' @example
#' # TODO
NULL

#' @export
#' @rdname il_gradebook_grades
il_gradebook_overall <- function(connection){
  # Overall grades from overall_score_cache table
  query <- "
  SELECT
  osc.cache_id,
  osc.student_id,
  osc.gradebook_id,
  osc.possible_points,
  osc.points_earned,
  osc.percentage,
  osc.mark,
  osc.missing_count,
  osc.assignment_count,
  osc.zero_count,
  osc.excused_count,
  osc.timeframe_start_date,
  osc.timeframe_end_date,
  osc.calculated_at,
  gb.created_by,
  gb.gradebook_name,
  gb.active,
  gb.academic_year,
  gb.is_deleted,
  users.first_name,
  users.last_name,
  users.local_user_id,
  students.local_student_id
  FROM gradebook.overall_score_cache As osc
  LEFT JOIN gradebook.gradebooks As gb ON gb.gradebook_id = osc.gradebook_id
  LEFT JOIN public.users As users ON users.user_id = gb.created_by
  LEFT JOIN public.students As students ON students.student_id = osc.student_id"
  message("Getting Overall Grade Data")
  DBI::dbGetQuery(connection, query)
}


#' @export
#' @rdname il_gradebook_grades
il_gradebook_categories <- function(connection){
  # Category grades from category_score_cache table
  query <- "
  SELECT
    cat.cache_id,
    cat.student_id,
    cat.gradebook_id,
    cat.category_id,
    cat.possible_points,
    cat.points_earned,
    cat.percentage,
    cat.category_name,
    cat.weight,
    cat.mark,
    cat.missing_count,
    cat.assignment_count,
    cat.zero_count,
    cat.excused_count,
    cat.calculated_at,
    cat.timeframe_start_date,
    cat.timeframe_end_date
  FROM gradebook.category_score_cache As cat
  LEFT JOIN gradebook.gradebooks ON gradebooks.gradebook_id = cat.gradebook_id"

  message("Getting Category Grade Data")
  DBI::dbGetQuery(connection, query)
}


#' @export
#' @rdname il_gradebook_grades
il_gradebook_standards <- function(connection){
  # Standards grades from standards_score_cache table.
  # TO DO: Join with standards table
  query <- "
  SELECT
  st.cache_id,
  st.gradebook_id,
  st.student_id,
  st.standard_id,
  st.percentage,
  st.mark,
  st.points_earned,
  st.possible_points,
  st.missing_count,
  st.assignment_count,
  st.zero_count,
  st.excused_count,
  st.timeframe_start_date,
  st.timeframe_end_date,
  st.calculated_at
  FROM gradebook.standards_cache As st
  LEFT JOIN gradebook.gradebooks ON gradebooks.gradebook_id = st.gradebook_id"

  message("Getting Standards Grade Data")
  DBI::dbGetQuery(connection, query)
}


#' @export
#' @rdname il_gradebook_grades
il_gradebook_assignments <- function(connection){
  # Assignment information from gradebook.assignments table.
  # TO DO: Join w categories table
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
  LEFT JOIN gradebook.gradebooks AS gb ON gb.gradebook_id = asg.gradebook_id
  LEFT JOIN public.users As users ON users.user_id = gb.created_by
  LEFT JOIN gradebook.categories As catname ON catname.category_id = asg.category_id WHERE catname.gradebook_id = asg.gradebook_id"

  message("Getting Assignment Information")
  DBI::dbGetQuery(connection, query)
}
