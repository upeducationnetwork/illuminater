#' Illuminate Gradebook Metadata
#'
#' Get metadata information about gradebooks, grading periods and the map between gradebooks and grading periods.
#'
#' @param connection The connection object from your \code{il_connect} call
#' @return A list of data frames for gradebooks, gradingperiods, and gradebooks_gradingperiods
#' @name il_gradebook_metadata
#' @import DBI
#' @import RPostgres
#' @export
#' @examples
#' c <- il_connect()
#' gb <- il_gradebook_metadata(c)
#' str(gb$gradebooks)
#' str(gb$gradebooks_gradingperiods)
#' str(gb$gradingperiods))
#' dbDisconnect(c)

il_gradebook_metadata <- function(connection){

  # Gradebook Info
  gradebooks <- il_gradebooks(connection)

  # Gradebook Grading Period Weights Info
  gradebooks_gradingperiods <- il_gradebooks_gradingperiods(connection)

  # Gradebook Grading Period Names
  gradingperiods <- il_gradingperiods(connection)

  result <- list(gradebooks = gradebooks,
                 gradebooks_gradingperiods = gradebooks_gradingperiods,
                 gradingperiods = gradingperiods)

  result
}

il_gradebooks <- function(connection){
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

il_gradebooks_gradingperiods <- function(connection){
  # Grading period to gradebook map
  query <- "
  SELECT
  gpweights.gradebook_id,
  gpweights.grading_period_id
  FROM gradebook.grading_period_weights As gpweights"

  message("Getting Grading Period Weight Data")
  DBI::dbGetQuery(connection, query)
}


il_gradingperiods <- function(connection){
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

