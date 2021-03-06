% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/logistic.R
\name{stochastic.logistic.regression}
\alias{stochastic.logistic.regression}
\title{Stochastic Logistic Regression}
\usage{
stochastic.logistic.regression(formula = NULL, pos_class = NULL,
  dim = NULL, intercept = TRUE, x0 = NULL, optimizer = "adaQN",
  optimizer_args = list(initial_step = 0.1, verbose = FALSE),
  lambda = 0.001, random_seed = 1, val_data = NULL)
}
\arguments{
\item{formula}{Formula for the model, if it is fit to data.frames instead of matrices/vectors.}

\item{pos_class}{If fit to data in the form of data.frames, a string indicating which of
the classes is the positive one. If fit to data in the form of matrices/vector, pass `NULL`.}

\item{dim}{Dimensionality of the model (number of features). Ignored when passing `formula` or when passing `x0`.
If the intercept is added from the option `intercept` here, it should not be counted towards `dim`.}

\item{intercept}{Whether to add an intercept to the covariates. Only ussed when fitting to matrices/vectors.
Ignored when passing formula (for formulas without intercept, put `-1` in the RHS to get rid of the intercept).}

\item{x0}{Initial values of the variables. If passed, will ignore `dim` and `random_seed`. If not passed,
will generate random starting values ~ Norm(0, 0.1).}

\item{optimizer}{The optimizer to use - one of `adaQN` (recommended), `SQN`, `oLBFGS`.}

\item{optimizer_args}{Arguments to pass to the optimizer (same ones as the functions of the same name).
Must be a list. See the documentation of each optimizer for the parameters they take.}

\item{lambda}{Regularization parameter. Be aware that the functions assume the log-likelihood (a.k.a. loss)
is divided by the number of observations, so this number should be small.}

\item{random_seed}{Random seed to use for the initialization of the variables. Ignored when passing `x0`.}

\item{val_data}{Validation data (only used for `adaQN`). If passed, must be a list with entries `X`,
`y` (if passing data.frames for fitting), and optionally `w` (sample weights).}
}
\value{
An object of class `stoch_logistic`, which can be fit to batches of data through functon `partial_fit_logistic`.
}
\description{
Stochastic Logistic Regression
}
\details{
Binary logistic regression, fit in batches using this package's own optimizers.
}
\examples{
library(stochQN)

### Load Iris dataset
data("iris")

### Example with X + y interface
X <- as.matrix(iris[, c("Sepal.Length", "Sepal.Width",
  "Petal.Length", "Petal.Width")])
y <- as.numeric(iris$Species == "setosa")

### Initialize model with default parameters
model <- stochastic.logistic.regression(dim = 4)

### Fit to 10 randomly-subsampled batches
batch_size <- as.integer(nrow(X) / 3)
for (i in 1:10) {
  set.seed(i)
  batch <- sample(nrow(X),
      size = batch_size, replace=TRUE)
  partial_fit_logistic(model, X, y)
}

### Check classification accuracy
cat(sprintf(
  "Accuracy after 10 iterations: \%.2f\%\%\\n",
  100 * mean(
    predict(model, X, type = "class") == y)
  ))


### Example with formula interface
iris_df <- iris
levels(iris_df$Species) <- c("setosa", "other", "other")

### Initialize model with default parameters
model <- stochastic.logistic.regression(Species ~ .,
  pos_class="setosa")

### Fit to 10 randomly-subsampled batches
batch_size <- as.integer(nrow(iris_df) / 3)
for (i in 1:10) {
  set.seed(i)
  batch <- sample(nrow(iris_df),
      size=batch_size, replace=TRUE)
  partial_fit_logistic(model, iris_df)
}
cat(sprintf(
  "Accuracy after 10 iterations: \%.2f\%\%\\n",
  100 * mean(
    predict(
      model, iris_df, type = "class") == iris_df$Species
      )
  ))
}
\seealso{
\link{partial_fit_logistic}, \link{coef.stoch_logistic} , \link{predict.stoch_logistic} , 
\link{adaQN} , \link{SQN}, \link{oLBFGS}
}
