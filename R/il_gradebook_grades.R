#' Gradebook Grades
#'
#' These functions will allow you to get gradebook grades out of Illuminate
#' \itemize{
#'  \item \code{il_gradebook_overall()}: Overall grades from points-based gradebooks
#'  \item \code{il_gradebook_categories()}: All category grades from points-based gradebooks
#'  \item \code{il_gradebook_standards()}: Standards grades in a gradebook
#' }
#'
#' Note that none of these are uniquely ID'd by gradebook +
#' student [+ category/standard]. The cache_id is the unique id.
#'
#'
#' @param connection The connection object from your \code{il_connect} call
#' @name il_gradebook_grades
#' @return A dataframe with the result of the call.
NULL

#' @export
#' @rdname il_gradebook_grades
il_gradebook_overall <- function(connection){
  # Overall grades from overall_score_cache table
  # TODO: Add academic year filter?
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
  INNER JOIN public.students As students ON students.student_id = osc.student_id"
  message("Getting Overall Grade Data")
  DBI::dbGetQuery(connection, query)
}

#' @export
#' @rdname il_gradebook_components
il_gradebook_categories <- function(connection){
  # Category  from category_score_cache table
  # TODO: Add gradebooks option to get specific gradebooks
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
    cat.timeframe_end_date,
    students.local_student_id
  FROM gradebook.category_score_cache As cat
  INNER JOIN gradebook.gradebooks ON gradebooks.gradebook_id = cat.gradebook_id
  INNER JOIN public.students As students ON students.student_id = cat.student_id"

  message("Getting Category Grade Data")
  DBI::dbGetQuery(connection, query)
}



#' @export
#' @rdname il_gradebook_components
il_gradebook_standards <- function(connection){
  # Standards grades from standards_score_cache table.
  # TO DO: Join with standards table, add gradebooks to get specific gradebooks
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
    st.calculated_at,
    students.local_student_id
  FROM gradebook.standards_cache As st
  INNER JOIN gradebook.gradebooks ON gradebooks.gradebook_id = st.gradebook_id
  INNER JOIN public.students As students ON students.student_id = st.student_id"

  message("Getting Standards Grade Data")
  DBI::dbGetQuery(connection, query)
}

