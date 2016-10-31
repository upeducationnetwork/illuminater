#' Illuminate Gradebook Metadata
#'
#' Get information about
#' 1. Gradebooks
#' 2. Overall scores
#' 3. Category and Standard scores,
#' 4. Assignments
#'
#' @param connection The connection object from your \code{il_connect} call
#' @param gradebook_id List of Illuminate IDs for each gradebook created this year
#' @return A list of data frames for gradebooks, overall gradebook scores, standards and category grades, and individual assignment details
#' @name il_gradebook_metadata
#' @import DBI
#' @import RPostgres
#' @export
#' @examples
#' c <- il_connect()
#' gb <- il_gradebook_metadata(c)
#' str(gb$overall_grades)
#' str(gb$category_grades)
#' str(gb$standards_grades)
#' str(gb$assignments)
#' dbDisconnect(c)

il_gradebook_metadata <- function(connection){

  # Gradebook Info
  gradebooks <- il_gradebook_info(connection)

  # Gradebook Grading Period Weights Info
  gpweights <- il_gpweights_info(connection)

  # Gradebook Grading Period Names
  gpname <- il_gpname_info(connection)

  # Overall Grades
  overall_grades <- il_gradebook_overall(connection)

  # Category Grades
  category_grades <- il_gradebook_category(connection)

  # Standards Grades
  standards_grades <- il_gradebook_standards(connection)

  # Assignments
  assignments <- il_gradebook_assignments(connection)

  result <- list(gradebooks = gradebooks,
                 gpweights = gpweights,
                 gpname = gpname,
                 overall_grades = overall_grades,
                 category_grades = category_grades,
                 standards_grades = standards_grades,
                 assignments = assignments)

  result
}

il_gradebook_info <- function(connection){
  # Gradebook metadata from gradebooks table
  query <- "
  SELECT
    gb.gradebook_id,
    gb.created_by,
    gb.gradebook_name,
    gb.active,
    gb.academic_year,
    gb.is_deleted
  FROM gradebook.gradebooks As gb"

  message("Getting Gradebook Metadata")
  DBI::dbGetQuery(connection, query)
}


il_user_info <- function(connection){
  # User information
  query <- "
  SELECT
   user.user_id,
   user.first_name,
   user.last_name,
   user.local_user_id
  FROM public.users As users"

  message("Getting User Data")
  DBI::dbGetQuery(connection, query)
}


il_gpweights_info <- function(connection){
  # Grading period weights
  query <- "
  SELECT
  gpweights.gradebook_id,
  gpweights.grading_period_id
  FROM gradebook.grading_period_weights As gpweights"

  message("Getting Grading Period Weight Data")
  DBI::dbGetQuery(connection, query)
}


il_gpname_info <- function(connection){
  # Grading period names
  query <- "
  SELECT
  gp.grading_period_id,
  gp.grading_period_name
  FROM public.grading_periods As gp"

  message("Getting Grading Period Data")
  DBI::dbGetQuery(connection, query)
}



il_categorynames_info <- function(connection){
  # Category Names
  query <- "
  SELECT
  catname.category_id,
  catname.category_name,
  catname.weight,
  catname.gradebook_id
  FROM gradebook.categories As catname"

  message("Getting Category Names Data")
  DBI::dbGetQuery(connection, query)
}

il_studentid_info <- function(connection){
  # Student IDs
  query <- "
  SELECT
  students.student_id,
  students.local_student_id
  FROM public.students As students."

  message("Getting Student Data")
  DBI::dbGetQuery(connection, query)
}




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


il_gradebook_category <- function(connection){
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
