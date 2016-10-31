
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
