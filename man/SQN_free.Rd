% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/optimizers_free.R
\name{SQN_free}
\alias{SQN_free}
\title{SQN Free-Mode Optimizer}
\usage{
SQN_free(mem_size = 10, bfgs_upd_freq = 20, min_curvature = 1e-04,
  y_reg = NULL, use_grad_diff = FALSE, check_nan = TRUE,
  nthreads = -1)
}
\arguments{
\item{mem_size}{Number of correction pairs to store for approximation of Hessian-vector products.}

\item{bfgs_upd_freq}{Number of iterations (batches) after which to generate a BFGS correction pair.}

\item{min_curvature}{Minimum value of (s * y) / (s * s) in order to accept a correction pair. Pass `NULL` for
no minimum.}

\item{y_reg}{Regularizer for 'y' vector (gets added y_reg * s). Pass `NULL` for no regularization.}

\item{use_grad_diff}{Whether to create the correction pairs using differences between gradients instead of Hessian-vector products.
These gradients are calculated on a larger batch than the regular ones (given by batch_size * bfgs_upd_freq).}

\item{check_nan}{Whether to check for variables becoming NaN after each iteration, and reverting the step if they do
(will also reset BFGS memory).}

\item{nthreads}{Number of parallel threads to use. If set to -1, will determine the number of available threads and use
all of them. Note however that not all the computations can be parallelized, and the BLAS backend might use a different
number of threads.}
}
\value{
An `SQN_free` object, which can be used through functions `update_gradient`, `update_hess_vec`,
and `run_SQN_free`
}
\description{
Optimizes an empirical (convex) loss function over batches of sample data. Compared to
function/class 'SQN', this version lets the user do all the calculations from the outside, only
interacting with the object by means of a function that returns a request type and is fed the
required calculation through methods 'update_gradient' and 'update_hess_vec'.

Order in which requests are made:
	
	========== loop ===========
	
	* calc_grad
	
\verb{   }... (repeat calc_grad)
  
if 'use_grad_diff':

\verb{    }* calc_grad_big_batch
	
else:

\verb{    }* calc_hess_vec
	
===========================

After running this function, apply `run_SQN_free` to it to get the first requested piece of information.
}
\examples{
### Example optimizing Rosenbrock 2D function
### Note that this example is not stochastic, as the
### function is not evaluated in expectation based on
### batches of data, but rather it has a given absolute
### form that never varies.
### Warning: this optimizer is meant for convex functions
### (Rosenbrock's is not convex)
library(stochQN)


fr <- function(x) { ## Rosenbrock Banana function
	x1 <- x[1]
	x2 <- x[2]
	100 * (x2 - x1 * x1)^2 + (1 - x1)^2
}
grr <- function(x) { ## Gradient of 'fr'
	x1 <- x[1]
	x2 <- x[2]
	c(-400 * x1 * (x2 - x1 * x1) - 2 * (1 - x1),
	  200 * (x2 - x1 * x1))
}
Hvr <- function(x, v) { ## Hessian of 'fr' by vector 'v'
	x1 <- x[1]
	x2 <- x[2]
	H <- matrix(c(1200 * x1^2 - 400*x2 + 2,
			  -400 * x1, -400 * x1, 200),
			nrow = 2)
	as.vector(H \%*\% v)
}

### Initial values of x
x_opt = as.numeric(c(0, 2))
cat(sprintf("Initial values of x: [\%.3f, \%.3f]\\n",
			x_opt[1], x_opt[2]))

### Will use constant step size throughout
### (not recommended)
step_size = 1e-3

### Initialize the optimizer
optimizer = SQN_free()

### Keep track of the iteration number
curr_iter <- 0

### Run a loop for severa, iterations
### (Note that some iterations might require more
###  than 1 calculation request)
for (i in 1:200) {
  req <- run_SQN_free(optimizer, x_opt, step_size)
  if (req$task == "calc_grad") {
    update_gradient(optimizer, grr(req$requested_on$req_x))
  } else if (req$task == "calc_hess_vec") {
	   update_hess_vec(optimizer,
      Hvr(req$requested_on$req_x, req$requested_on$req_vec))
  }

  ### Track progress every 10 iterations
  if (req$info$iteration_number > curr_iter) {
  	curr_iter <- req$info$iteration_number
  }
  if ((curr_iter \%\% 10) == 0) {
  	cat(sprintf(
  	 "Iteration \%3d - Current function value: \%.3f\\n",
  	 req$info$iteration_number, fr(x_opt)))
  }
}
cat(sprintf("Current values of x: [\%.3f, \%.3f]\\n",
			x_opt[1], x_opt[2]))
}
\references{
\itemize{ \item Byrd, R.H., Hansen, S.L., Nocedal, J. and Singer, Y., 2016.
"A stochastic quasi-Newton method for large-scale optimization."
SIAM Journal on Optimization, 26(2), pp.1008-1031.
\item Wright, S. and Nocedal, J., 1999. "Numerical optimization." (ch 7) Springer Science, 35(67-68), p.7.}
}
\seealso{
\link{update_gradient} , \link{update_hess_vec} , \link{run_oLBFGS_free}
}
