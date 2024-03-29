#' @title Block
#'
#' @description Class used within the package to keep the structure and
#' information about the generated blocks.
#'
#' @slot features a vector of numeric which contains the indices of the block.
#' @slot explained_variance a numeric which contains the variance explained of
#' the blocks variables based on the whole data set.
#' @slot is_valid a logical which indicates if the block structure is valid.
#' @slot ev_influenced a vector of numeric which contains the indices of the
#' eigenvectors influenced by this block.
#' @export
setClass(
  "Block",
  representation(
    features="vector",
    explained_variance="numeric",
    is_valid="logical",
    ev_influenced="vector"
  ),
  prototype(explained_variance=0, is_valid=TRUE)
)

#' @title Block - Show
#'
#' @description Prints the blocks structure.
#'
#' @param object block.
#'
#' @return
#' No return value.
#'
#' @examples
#' block <- new("Block", features=c(2, 5), explained_variance=0.03)
#' print(block)
setMethod(
  f="show",
  signature="Block",
  definition=function(object) {
    print(str(object))
  }
)

#' @title Block - str
#'
#' @description Generic function to create a string out of the blocks structure.
#'
#' @param object block.
#'
#' @return
#' A string representing the Block.
#'
#' @examples
#' block <- new("Block", features=c(2, 5), explained_variance=0.03)
#' str(block)
#' @export
setMethod(
  f="str",
  signature="Block",
  definition=function(object) {
    features <- paste(unlist(object@features), collapse=", ")
    expvar <- round(object@explained_variance * 100, 2)
    if (object@is_valid) {
      str <- paste(
        "Features (",
        features,
        ") explain ",
        expvar,
        "% of the overall explained variance",
        sep=""
      )
    } else {
      str <- paste(
        "Features (",
        features,
        ") remain without a block structure row-wise.",
        sep=""
      )
    }

    return(str)
  }
)
