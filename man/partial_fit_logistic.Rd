% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/logistic.R
\name{partial_fit_logistic}
\alias{partial_fit_logistic}
\title{Update stochastic logistic regression model with new batch of data}
\usage{
partial_fit_logistic(logistic_model, X, y = NULL, w = NULL)
}
\arguments{
\item{logistic_model}{A `stoch_logistic` object as output by function `stochastic.logistic.regression`.
Will be modified in-place.}

\item{X}{Data with covariates. If passing a `data.frame`, the model object must have been initialized
with a formula, and `X` must also contain the target variable (`y`). If passing a matrix, must
also pass `y`. Note that whatever factor levels are present in the first batch of data, will be taken as the
whole factor levels.}

\item{y}{The target variable, when using matrices. Ignored when using formula.}

\item{w}{Sample weights (optional). If required, must pass them at every partial fit iteration.}
}
\value{
No return value. Model object is updated in-place.
}
\description{
Perform a quasi-Newton iteration to update the model with new data.
}
\seealso{
\link{stochastic.logistic.regression}
}
