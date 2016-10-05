#' Initiate connection to Illuminate
#'
#' Uses your environment variables to connect to Illuminate
#' @keywords illuminater, connect
#' @import DBI
#' @import RPostgres
#' @export
#' @examples
#' c <- il_connect()
#' dbDisconnect(c)
il_connect <- function(){
  user <- Sys.getenv('IL_USER')
  db_pass <- Sys.getenv('IL_PASS')
  db_name <- Sys.getenv('IL_DB')
  host <- Sys.getenv('IL_HOST')
  port <- Sys.getenv('IL_PORT')
  
  DBI::dbConnect(RPostgres::Postgres(),
            user = user,
            password = db_pass,
            dbname = db_name,
            host=host,
            port=port)  
}
