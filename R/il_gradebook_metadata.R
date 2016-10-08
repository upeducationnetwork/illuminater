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
#' gradebook_ids <- list(250, 399, 192) JK question - will leaving this blank return all?
#' gb <- il_gradebook_metadata(c, gradebook_ids)
#' str(gb$overall_grades)
#' str(gb$category_grades)
#' str(gb$standards_grades)
#' str(gb$assignments)
#' dbDisconnect(c)

il_gradebook_metadata <- function(connection, gradebook_ids){

# Gradebook Info
gradebooks <- il_gradebook_info(connection, gradebook_ids)

# Overall Grades
overall_grades <- il_gradebook_overall(connection, gradebook_ids)

# Category Grades
category_grades <- il_gradebook_category(connection, gradebook_ids)

# Standards Grades
standards_grades <- il_gradebook_standards(connection, gradebook_ids)

# Assignments
assignments <- il_gradebook_assignments(connection, gradebook_ids)

result <- list(gradebooks = gradebooks,
               overall_grades = overall_grades,
               category_grades = category_grades,
               standards_grades = standard_grades,
               assignments = assignments)

result
}

il_gradebook_info <- function(connection, gradebook_ids){
  # Gradebook metadata from gradebooks table
  query <- "
  SELECT
    gradebook_id,
    created_by,
    gradebook_name,
    active,
    academic_year,
    is_deleted
  FROM gradebook.gradebooks
  WHERE gradebook_id IN (%s)"

  message("Getting Gradebook Metadata")
  DBI::dbGetQuery(connection, build_query(query, gradebook_ids))
}


il_gradebook_overall <- function(connection, gradebook_ids){
  # Overall grades from overall_score_cache table
  query <- "
  SELECT
    cache_id,
    student_id,
    gradebook_id,
    possible_points,
    points_earned,
    percentage,
    mark,
    missing_count,
    assignment_count,
    zero_count,
    excused_count,
    timeframe_start_date,
    timeframe_end_date,
    calculated_at
  FROM gradebook.overall_score_cache
  LEFT JOIN gradebook.gradebooks ON gradebook_id = gradebook_id
  WHERE gradebook_id IN (%s)"

  message("Getting Overall Grade Data")
  DBI::dbGetQuery(connection, build_query(query, gradebook_ids))
}


il_gradebook_category <- function(connection, gradebook_ids){
  # Category grades from category_score_cache table
  query <- "
  SELECT
    cache_id,
    student_id,
    gradebook_id,
    category_id,
    possible_points,
    points_earned,
    percentage,
    category_name,
    weight,
    mark,
    missing_count,
    assignment_count,
    zero_count,
    excused_count,
    calculated_at,
    timeframe_start_date,
    timeframe_end_date,
  FROM gradebook.category_score_cache
  LEFT JOIN gradebook.gradebooks ON gradebook_id = gradebook_id
  WHERE gradebook_id IN (%s)"

  message("Getting Category Grade Data")
  DBI::dbGetQuery(connection, build_query(query, gradebook_ids))
}


il_gradebook_standards <- function(connection, gradebook_ids){
  # Standards grades from standards_score_cache table.
  # TO DO: Join with standards table
  query <- "
  SELECT
    cache_id,
    gradebook_id,
    student_id,
    standard_id,
    percentage,
    mark,
    points_earned,
    possible_points,
    missing_count,
    assignment_count,
    zero_count,
    excused_count,
    timeframe_start_date,
    timeframe_end_date,
    calculated_at
  FROM gradebook.standards_cache
  LEFT JOIN gradebook.gradebooks ON gradebook_id = gradebook_id
  WHERE gradebook_id IN (%s)"

  message("Getting Standards Grade Data")
  DBI::dbGetQuery(connection, build_query(query, gradebook_ids))
}

il_gradebook_assignments <- function(connection, gradebook_ids){
  # Assignment information from gradebook.assignments table.
  # TO DO: Join w categories table
  query <- "
  SELECT
    assignment_id,
    short_name,
    long_name,
    assign_date,
    due_date,
    possible_points,
    category_id,
    is_active,
    description,
    _grading_period_id,
    auto_score_type,
    auto_score_id,
    possible_score,
    gradebook_id,
    last_modified_by,
    is_extra_credit,
    tags
  FROM gradebook.standards_cache
  LEFT JOIN gradebook.gradebooks ON gradebook_id = gradebook_id
  WHERE gradebook_id IN (%s)"

  message("Getting Assignment Information")
  DBI::dbGetQuery(connection, build_query(query, gradebook_ids))
}

