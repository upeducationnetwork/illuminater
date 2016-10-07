
build_query <- function(query, filter_ids){
  # Approach is to build SQL queries then substitute assessment ids for each table
  sprintf(query, paste(filter_ids, collapse = ","))
}


