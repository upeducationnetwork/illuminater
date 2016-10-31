ndups <- function(x) sum(duplicated(x))

test_that("il_gradebook_metadata returns list of dataframes with expected IDs", {

  c <- il_connect()

  df_list <- il_gradebook_metadata(c)

  # Test types
  expect_is(df_list, "list")
  expect_is(df_list$gradebooks, "data.frame")
  expect_is(df_list$gradebooks_gradingperiods, "data.frame")
  expect_is(df_list$gradingperiods, "data.frame")

  # Test IDs
  expect_equal(ndups(df_list$gradebooks$gradebook_id), 0)
  expect_equal(ndups(df_list$gradebooks_gradingperiods[ , c("gradebook_id", "grading_period_id")]), 0)
  expect_equal(ndups(df_list$gradingperiods$grading_period_id), 0)

  dbDisconnect(c)
})


test_that("il_gradebook_grades methods return dataframes with expected IDs", {

  c <- il_connect()

  overall <- il_gradebook_overall(c)
  categories <- il_gradebook_categories(c)
  standards <- il_gradebook_standards(c)
  assignments <- il_gradebook_assignments(c)

  # Test types
  expect_is(overall, "data.frame")
  expect_is(categories, "data.frame")
  expect_is(standards, "data.frame")
  expect_is(assignments, "data.frame")

  # Test IDs
  expect_equal(ndups(overall[ , c("cache_id")]), 0)     # Not uniquely ID'd by gradebook + student. Watch out!
  expect_equal(ndups(categories[ , c("cache_id")]), 0)  # Not uniquely ID'd by gradebook + student + category. Watch out!
  expect_equal(ndups(standards[ , c("cache_id")]), 0)   # Not uniquely ID'd by gradebook + student + standard. Watch out!

  dbDisconnect(c)
})


test_that("il_gradebook_components methods return dataframes with expected IDs", {

  c <- il_connect()

  assignments <- il_gradebook_assignments(c)

  # Test types
  expect_is(assignments, "data.frame")

  # Test IDs
  expect_equal(ndups(assignments$assignment_id), 0)

  dbDisconnect(c)
})


