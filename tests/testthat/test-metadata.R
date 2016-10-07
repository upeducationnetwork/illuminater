library(illuminater)

test_that("il_assessment_metadata returns list of dataframes", {

  c <- il_connect()

  df_list <- il_assessment_metadata(c, list(18680, 18672))

  expect_is(df_list, "list")
  expect_is(df_list$assessments, "data.frame")
  expect_is(df_list$fields, "data.frame")
  expect_is(df_list$field_responses, "data.frame")
  expect_is(df_list$field_standards, "data.frame")

  dbDisconnect(c)
})


test_that("il_assessment_metadata dataframes have expected Id vars", {

  c <- il_connect()

  df_list <- il_assessment_metadata(c, list(18680, 18672))

  ndups <- function(x) sum(duplicated(x))

  expect_equal(ndups(df_list$assessments$assessment_id), 0)
  expect_equal(ndups(df_list$fields$field_id), 0)
  expect_equal(ndups(df_list$field_responses$field_response_id), 0)
  expect_equal(ndups(df_list$field_standards[ , c("field_id", "standard_id")]), 0)

  dbDisconnect(c)
})
