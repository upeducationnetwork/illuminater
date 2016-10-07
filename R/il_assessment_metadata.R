#' Illuminate Assessment Metadata
#'
#' Get metadata for an assessment out of Illuminate.
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
#' @param assessment_ids List of Illuminate IDs of the assessments you want
#' @return A list of data frames for each of assessments, fields, field response points and standards
#' @name il_assessment_metadata
#' @import DBI
#' @import RPostgres
#' @export
#' @examples
#' c <- il_connect()
#' assessment_ids <- list(18672, 18657, 18677, 18679)
#' assess <- il_assessment_metadata(c, assessment_ids)
#' str(assess$assessments)
#' str(assess$fields)
#' str(assess$standards)
#' dbDisconnect(c)

il_assessment_metadata <- function(connection, assessment_ids){
  # TODO: Write a trycatch for the DBI call to make error catching easier.
  # Get assessment, field and standard metadata

  # Assessments
  assessments <- il_assessement_info(connection, assessment_ids)

  # Fields
  fields <- il_assessment_fields(connection, assessment_ids)

  # Field Responses
  field_responses <- il_assessment_field_responses(connection, assessment_ids)

  # Standards
  field_standards <- il_assessment_field_standards(connection, assessment_ids)

  result <- list(assessments = assessments,
                 fields = fields,
                 field_responses=field_responses,
                 field_standards = field_standards)

  result
}


il_assessement_info <- function(connection, assessment_ids){
  # Assessment metadata from assessments table
  query <- "
    SELECT
      assessment_id,
      title,
      description,
      user_id,
      created_at,
      updated_at,
      deleted_at,
      administered_at,
      academic_year,
      local_assessment_id,
      tags,
      administration_window_start_date,
      administration_window_end_date
    FROM dna_assessments.assessments
    WHERE assessment_id IN (%s)"

  message("Getting Assessment Metadata")
  DBI::dbGetQuery(connection, build_query(query, assessment_ids))
}


il_assessment_fields <- function(connection, assessment_ids){
  # Data from Fields table

  query <- "
    SELECT
      fields.field_id,
      fields.assessment_id,
      fields.order,
      fields.factor,
      fields.maximum,
      fields.created_at,
      fields.updated_at,
      fields.deleted_at,
      fields.body,
      fields.is_rubric,
      fields.sheet_label,
      fields.extra_credit,
      fields.item_rev_id,
      fields.is_advanced
    FROM dna_assessments.fields
    WHERE fields.assessment_id IN (%s)
    "
  message("Getting Field Metadata")
  DBI::dbGetQuery(connection, build_query(query, assessment_ids))
}


il_assessment_field_responses <- function(connection, assessment_ids){
  # Get all scored student responses for an assessment. Responses worth zero points are not counted.

  query <- "
  SELECT
    fr.field_id,
    fr.field_response_id,
    fr.response_id,
    fr.version_id,
    fr.points,
    fr.choice,
    fr.rationale,
    r.response
    FROM dna_assessments.field_responses As fr
    LEFT JOIN dna_assessments.fields As f ON f.field_id = fr.field_id
    LEFT JOIN dna_assessments.responses As r on r.response_id = fr.response_id
    WHERE f.assessment_id IN (%s)
  "
  message("Getting Field Responses")
  DBI::dbGetQuery(connection, build_query(query, assessment_ids))
}


il_assessment_field_standards <- function(connection, assessment_ids){

  # TODO: What is category ID? What is subject ID? Make this an export function? (Probably!)
  query <- "
  SELECT
    f.assessment_id,
    f.field_id,
    fs.standard_id,
    standards.parent_standard_id,
    standards.category_id,
    standards.subject_id,
    standards.state_num,
    standards.label,
    standards.seq,
    standards.level,
    standards.stem,
    standards.description,
    standards.custom_code
  FROM dna_assessments.fields as f
  LEFT JOIN dna_assessments.field_standards As fs ON fs.field_id = f.field_id
  LEFT JOIN standards.standards ON standards.standard_id = fs.standard_id
  WHERE f.assessment_id IN (%s)
  "

  message("Getting Standards Data")
  DBI::dbGetQuery(connection, build_query(query, assessment_ids))
}


build_query <- function(query, filter_ids){
  # Approach is to build SQL queries then substitute assessment ids for each table
  sprintf(query, paste(filter_ids, collapse = ","))
}
# Add a scanned flag!
