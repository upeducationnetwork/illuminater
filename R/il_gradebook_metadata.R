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
#' gradebook_ids <- list(250, 399, 192) ## JK question - will leaving this blank return all?
#' gb <- il_gradebook_details(c, gradebook_ids)
#' str(gb$overall)
#' str(gb$categories)
#' str(gb$standards)
#' str(gb$assignments)
#' dbDisconnect(c)
#'
#' il_assessment_metadata <- function(connection, assessment_ids){
# TODO: Write a trycatch for the DBI call to make error catching easier.
# Get assessment, field and standard metadata

# Gradebook Info
gradebooks <- il_gradebook_info(connection, gradebook_ids)

# Overall Grades
overall_grades <- il_gradebook_overall(connection, gradebook_ids)

# Category Grades
category_grades <- il_gradebook_category(connection, gradebook_ids)

# Standards Grades
standards_grades <- il_gradebook_standards(connection, gradebook_ids)

# Assignments
assignments <- il_gradebook_assignments(connection, assessment_ids)

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
  WHERE gradebook_id IN (%s)"

  message("Getting Category Grade Data")
  DBI::dbGetQuery(connection, build_query(query, gradebook_ids))
}


il_gradebook_standards <- function(connection, gradebook_ids){
  # Standards grades from standards_score_cache table
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
  WHERE gradebook_id IN (%s)"

  message("Getting Standards Grade Data")
  DBI::dbGetQuery(connection, build_query(query, gradebook_ids))
}



