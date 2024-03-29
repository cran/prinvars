% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pla.R
\name{spla}
\alias{spla}
\title{Sparse Principal Loading Analysis}
\usage{
spla(
  x,
  method = c("pmd", "spca"),
  para,
  cor = FALSE,
  criterion = c("corrected", "normal"),
  threshold = 1e-07,
  rho = 1e-06,
  max.iter = 200,
  trace = FALSE,
  eps.conv = 0.001,
  orthogonal = TRUE,
  check = c("rnc", "rows"),
  ...
)
}
\arguments{
\item{x}{a numeric matrix or data frame which provides the data for the
sparse principal loading analysis.}

\item{method}{chooses the methods to calculate the sparse loadings.
\code{pmd} uses the method from Witten et al. (2009) and \code{spca} uses the
method from Zou et al. (2006).}

\item{para}{when \code{method="pmd"}: an integer giving the bound for the
L1 regularization. When \code{method="spca"}: a vector containing the
regularization parameter for each variable.}

\item{cor}{a logical value indicating whether the calculation should use the
correlation or the covariance matrix.}

\item{criterion}{a character string indicating if the weight-corrected
evaluation criterion (CEC) or the evaluation criterion (EC) is used.
\code{corrected} changes the loadings to weight all variables equally while
\code{normal} does not change the loadings.}

\item{threshold}{a numeric value used to determine zero elements in the
loading. This serves mostly to correct approximation errors.}

\item{rho}{penalty parameter. When \code{method="SPCA"}, we need further
regularizations for the case when the number of variables is larger than the
number of observations. We refer to Zou et al. (2006) and Bauer (2022) for
more details.}

\item{max.iter}{maximum number of iterations.}

\item{trace}{a logical value indicating if the progress is printed.}

\item{eps.conv}{a numerical value as convergence criterion.}

\item{orthogonal}{a logical value indicating if the sparse loadings are
orthogonalized.}

\item{check}{a character string indicating if only rows or rows as well as
columns are used to detect the underlying block structure. \code{rows} checks
if the rows fulfill the required structure. \code{rnc} checks if rows and
columns fulfill the required structure.}

\item{...}{further arguments passed to or from other methods.}
}
\value{
single or list of \code{pla} class containing the following attributes:
\item{x}{
  a numeric matrix or data frame which equals the input of \code{x}.
}
\item{EC}{
  a numeric vector that contains the weight-corrected evaluation criterion
  (CEC) if \code{criterion="corrected"} and the evaluation criterion (EC) if
  \code{criterion="normal"}.
}
\item{loadings}{
  a matrix of variable loadings (i.e. a matrix containing the sparse
  loadings).
}
\item{blocks}{
  a list of blocks which are identified by sparse principal loading analysis.
}
\item{W}{
  a matrix of variable loadings used to calculate the evaluation criterion.
  If \code{criterion="corrected"}, \code{W} contains an orthogonal matrix
  with equal weights in the first column of each loading-block. If
  \code{criterion="normal"}, \code{W} are the \code{loadings}.
}
}
\description{
This function performs sparse principal loading analysis
on the given data matrix. We refer to Bauer (2022) for more information.
The corresponding sparse loadings are calculated either using \code{PMD} from
the \code{PMA} package or using \code{spca} from the \code{elasticnet}
package. The respective methods are given by Zou et al. (2006) and Witten et
al. (2009) respectively.
}
\examples{
#############
## First example: we apply SPLA to a classic example from PCA
#############

spla(USArrests, method = "spca", para=c(0.5, 0.5, 0.5, 0.5), cor=TRUE)

## we obtain two blocks:
## 1x1 (Urbanpop) and 3x3 (Murder, Aussault, Rape).
## The large CEC of 0.922 indicates that the given structure is reasonable.

spla(USArrests, method = "spca", para=c(0.5, 0.5, 0.7, 0.5), cor=TRUE)

## we obtain three blocks:
## 1x1 (Urbanpop), 1x1 (Rape) and 2x2 (Murder, Aussault).
## The mid-ish CEC of 0.571 for (Murder, Aussault) indicates that the found 
## structure might not be adequate.

#############
## Second example: we replicate a synthetic example similar to Bauer (2022)
#############

set.seed(1)
N = 500
V1 = rnorm(N,0,10)
V2 = rnorm(N,0,11)

## Create the blocks (X_1,...,X_4) and (X_5,...,X_8) synthetically

X1 = V1 + rnorm(N,0,1) #X_j = V_1 + N(0,1) for j =1,...,4
X2 = V1 + rnorm(N,0,1)
X3 = V1 + rnorm(N,0,1)
X4 = V1 + rnorm(N,0,1)

X5 = V2 + rnorm(N,0,1) #X_j = V_1 + N(0,1) for j =5,...9
X6 = V2 + rnorm(N,0,1)
X7 = V2 + rnorm(N,0,1)
X8 = V2 + rnorm(N,0,1)

X = cbind(X1, X2, X3, X4, X5, X6, X7, X8)

## Conduct SPLA to obtain the blocks (X_1,...,X_4) and (X_5,...,X_8)

## use method = "pmd" (default)
spla(X, para = 1.4)

## use method = "spca"
spla(X, method = "spca", para = c(500,60,3,8,5,7,13,4))

}
\references{
\insertRef{Bauer.2022}{prinvars}
\insertRef{Witten.2009}{prinvars}
\insertRef{Zou.2006}{prinvars}
}
