% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/il_gradebook_grades.R
\name{il_gradebook_grades}
\alias{il_gradebook_grades}
\alias{il_gradebook_overall}
\title{Gradebook Grades}
\usage{
il_gradebook_overall(connection)
}
\arguments{
\item{connection}{The connection object from your \code{il_connect} call}
}
\value{
A dataframe with the result of the call.
}
\description{
These functions will allow you to get gradebook grades out of Illuminate
\itemize{
 \item \code{il_gradebook_overall()}: Overall grades from points-based gradebooks
 \item \code{il_gradebook_categories()}: All category grades from points-based gradebooks
 \item \code{il_gradebook_standards()}: Standards grades in a gradebook
}
}
\details{
Note that none of these are uniquely ID'd by gradebook +
student [+ category/standard]. The cache_id is the unique id.
}

