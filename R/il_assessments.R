#' il_assessments
#'
#' Get assessment data out of Illuminate
#' @keywords illuminater, assessment
#' @import DBI
#' @import RPostgres
#' @export
#' @examples
#' c <- il_connect()
#' assess <- il_assess()
#' dbDisconnect(c)



query <- "SELECT * FROM dna_assessments.assessments WHERE assessment_id IN (%s)"
assess <- dbGetQuery(connection, sprintf(query, paste(ids, collapse = ","))
