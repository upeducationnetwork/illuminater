#' Illuminate Assessment Responses
#'
#' Get individual responses for an assessment out of Illuminate.
#'
#' The intended workflow is
#'
#'  - Get the metadata once, or once a week, or whatever
#'  - Get responses much more frequently and merge with stored metadata
#'
#' There is relatively little behind-the-scenes joining,
#' instead returning a list of tidy data that the user can combine.
#'
#' @param connection The connection object from your \code{il_connect} call
#' @param assessment_ids The Illuminate IDs of the assessments you want
#' @return A list of data frames for each of student_assessments, student_responses and scanning_info (empty for now)
#' @name il_assessment_responses
#' @import DBI
#' @import RPostgres
#' @export
#' @examples
#' c <- il_connect()
#' assessment_ids <- list(18672, 18657, 18677, 18679)
#' resps <- il_assessment_responses(c, assessment_ids)
#' str(resps$students)
#' str(resps$student_responses)
#' str(resps$scanning_info)
#' dbDisconnect(c)
#'
il_assessment_responses <- function(connection, assessment_ids){
  # Get all students who took an assessment, their responses and scan data
  student_assessments <- il_assessment_students(connection, assessment_ids)
  student_responses <- il_assessment_student_responses(connection, assessment_ids)
  scanning_info <- il_assessment_scans(connection, assessment_ids)

  result <- list(student_assessments=student_assessments, student_responses=student_responses, scanning_info=scanning_info)

  result
}


il_assessment_students <- function(connection, assessment_ids){
  # Get information about students who took a given assessment

  query <- "
  SELECT
    sa.student_assessment_id,
    sa.assessment_id,
    sa.version_id,
    sa.student_id,
    sa.date_taken,
    sa.created_at,
    sa.updated_at,
    s.first_name,
    s.last_name,
    s.local_student_id,
    s.state_student_id
  FROM dna_assessments.students_assessments As sa
  LEFT JOIN public.students As s ON s.student_id = sa.student_id
  WHERE sa.assessment_id IN (%s)
  "

  message("Getting Student Assessment Data")
  DBI::dbGetQuery(connection, build_query(query, assessment_ids))
}

il_assessment_student_responses <- function(connection, assessment_ids){
  # Get all student responses for a given assessment

  # There is nothing in UP's text response table now... I wonder what that is?

  query <- "
    SELECT
    sar.assessment_id,
    sar.student_assessment_id,
    sar.student_assessment_response_id,
    sar.field_id,
    sar.response_id,
    sar.version_id,
    r.response,
    fr.points
    FROM dna_assessments.students_assessments_responses As sar
    LEFT JOIN dna_assessments.responses As r ON r.response_id = sar.response_id
    LEFT JOIN dna_assessments.field_responses As fr ON
      fr.response_id = sar.response_id AND
      fr.version_id = sar.version_id AND
      fr.field_id = sar.field_id
    WHERE sar.assessment_id IN (%s)
      "
  message("Getting Student Assessment Responses")
  DBI::dbGetQuery(connection, build_query(query, assessment_ids))
}

il_assessment_scans <- function(connection, assessment_ids){
  # Get amount of scanning data for a given assessment / list of assessments

  query <- "
    SELECT
      COUNT(*) As number_scan_rows
    FROM dna_assessments.scanned_sheets
    WHERE assessment_id IN (%s)
    GROUP BY
      assessment_id,
      student_id
  "
  message("Getting Assessment Scan Data")
  DBI::dbGetQuery(connection, build_query(query, assessment_ids))
}


