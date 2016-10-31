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

