library(illuminater)

test_that("il_assessment_responses returns list of dataframes", {

  c <- il_connect()

  df_list <- il_assessment_responses(c, list(18680, 18672))

  expect_is(df_list, "list")
  expect_is(df_list$student_assessments, "data.frame")
  expect_is(df_list$student_responses, "data.frame")
  # No test for scanning bc there's no data

  dbDisconnect(c)
})


test_that("il_assessment_responses dataframes have expected Id vars", {

  c <- il_connect()

  df_list <- il_assessment_responses(c, list(18680, 18672))

  ndups <- function(x) sum(duplicated(x))

  expect_equal(ndups(df_list$student_responses$student_assessment_response_id), 0)
  expect_equal(ndups(df_list$student_assessments$student_assessment_id), 0)

  dbDisconnect(c)
})
